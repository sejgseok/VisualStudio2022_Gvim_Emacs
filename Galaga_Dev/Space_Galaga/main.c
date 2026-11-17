/* main.c - Win32 창, 메시지 루프, 고정 간격 업데이트, 더블 버퍼링을 담당합니다.
   C++ 문법이나 게임 엔진을 사용하지 않는 순수 C / Windows API 프로그램입니다. */
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <windowsx.h>
#include "game.h"

static Game g_game;
static HDC g_backDC;
static HBITMAP g_backBitmap;
static HGDIOBJ g_oldBitmap;
static LARGE_INTEGER g_frequency, g_previous;
static double g_accumulator;
static BOOL g_clockReady;
static BOOL g_fullscreen;
static WINDOWPLACEMENT g_windowPlacement = { sizeof(WINDOWPLACEMENT) };

/* F11은 현재 모니터 전체를 사용하는 테두리 없는 전체 화면으로 전환합니다.
   원래 창 위치와 크기를 보관하므로 다시 누르면 이전 창으로 정확히 복귀합니다. */
static void ToggleFullscreen(HWND window)
{
    if (!g_fullscreen) {
        MONITORINFO monitor = { sizeof(MONITORINFO) };
        if (!GetWindowPlacement(window, &g_windowPlacement) ||
            !GetMonitorInfoW(MonitorFromWindow(window, MONITOR_DEFAULTTONEAREST), &monitor)) return;
        SetWindowLongPtrW(window, GWL_STYLE, WS_POPUP | WS_VISIBLE);
        SetWindowPos(window, HWND_TOP, monitor.rcMonitor.left, monitor.rcMonitor.top,
            monitor.rcMonitor.right - monitor.rcMonitor.left,
            monitor.rcMonitor.bottom - monitor.rcMonitor.top, SWP_FRAMECHANGED);
        g_fullscreen = TRUE;
    } else {
        SetWindowLongPtrW(window, GWL_STYLE, WS_OVERLAPPEDWINDOW | WS_VISIBLE);
        SetWindowPlacement(window, &g_windowPlacement);
        SetWindowPos(window, NULL, 0, 0, 0, 0,
            SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
        g_fullscreen = FALSE;
    }
}

/* 실제 클라이언트 영역에 논리 화면을 비율 유지하여 확대합니다.
   남는 영역은 검정색으로 칠하므로 창을 늘려도 기체와 적이 찌그러지지 않습니다. */
static void PaintGame(HWND window, HDC dc)
{
    RECT client;
    int width, height, drawWidth, drawHeight, left, top;
    GetClientRect(window, &client);
    width = client.right;
    height = client.bottom;
    if (!g_backDC || width <= 0 || height <= 0) return;
    GameDraw(&g_game, g_backDC);
    drawWidth = width;
    drawHeight = MulDiv(width, GAME_HEIGHT, GAME_WIDTH);
    if (drawHeight > height) {
        drawHeight = height;
        drawWidth = MulDiv(height, GAME_WIDTH, GAME_HEIGHT);
    }
    left = (width - drawWidth) / 2;
    top = (height - drawHeight) / 2;
    /* 실제 게임 영역을 먼저 검정색으로 지우면 큰 전체 화면에서 느린 확대 복사
       사이에 검은 프레임이 노출됩니다. 게임 영역은 완성된 백 버퍼로 한 번만
       덮어쓰고, 화면비 유지로 생긴 바깥 여백만 따로 지웁니다. */
    if (top > 0) PatBlt(dc, 0, 0, width, top, BLACKNESS);
    if (height > top + drawHeight)
        PatBlt(dc, 0, top + drawHeight, width, height - top - drawHeight, BLACKNESS);
    if (left > 0) PatBlt(dc, 0, top, left, drawHeight, BLACKNESS);
    if (width > left + drawWidth)
        PatBlt(dc, left + drawWidth, top, width - left - drawWidth, drawHeight, BLACKNESS);
    /* HALFTONE 보간은 작은 모니터로 축소할 때 한글 획이 소실되는 현상을 줄입니다. */
    SetStretchBltMode(dc, HALFTONE);
    SetBrushOrgEx(dc, 0, 0, NULL);
    StretchBlt(dc, left, top, drawWidth, drawHeight, g_backDC,
        0, 0, GAME_WIDTH, GAME_HEIGHT, SRCCOPY);
}

/* WM_TIMER의 간격은 운영체제 상황에 따라 달라집니다. 성능 카운터로 실제 경과
   시간을 측정한 뒤 1/120초 단위로 나누어, PC 속도와 무관한 물리 속도를 유지합니다.
   창 이동이나 디버거 중단 후에는 최대 0.1초만 처리하여 갑작스러운 순간이동을 막습니다. */
static void Tick(HWND window)
{
    LARGE_INTEGER now;
    double elapsed;
    const double step = 1.0 / 120.0;
    QueryPerformanceCounter(&now);
    if (!g_clockReady) { g_previous = now; g_clockReady = TRUE; }
    elapsed = (double)(now.QuadPart - g_previous.QuadPart) / (double)g_frequency.QuadPart;
    g_previous = now;
    if (elapsed > 0.1) elapsed = 0.1;
    g_accumulator += elapsed;
    while (g_accumulator >= step) {
        GameUpdate(&g_game, (float)step);
        g_accumulator -= step;
    }
    InvalidateRect(window, NULL, FALSE);
}

static LRESULT CALLBACK WindowProc(HWND window, UINT message, WPARAM wParam, LPARAM lParam)
{
    switch (message) {
    case WM_CREATE: {
        HDC dc = GetDC(window);
        g_backDC = CreateCompatibleDC(dc);
        g_backBitmap = CreateCompatibleBitmap(dc, GAME_WIDTH, GAME_HEIGHT);
        ReleaseDC(window, dc);
        if (!g_backDC || !g_backBitmap) return -1;
        g_oldBitmap = SelectObject(g_backDC, g_backBitmap);
        GameInit(&g_game);
        QueryPerformanceFrequency(&g_frequency);
        if (!SetTimer(window, 1, 8, NULL)) return -1;
        return 0;
    }
    case WM_TIMER:
        if (wParam == 1) Tick(window);
        return 0;
    case WM_KEYDOWN:
        if (wParam == VK_ESCAPE) { DestroyWindow(window); return 0; }
        if (wParam == VK_F11) {
            if ((lParam & (1L << 30)) == 0) ToggleFullscreen(window);
            return 0;
        }
        GameKey(&g_game, (UINT)wParam, TRUE, (lParam & (1L << 30)) != 0);
        return 0;
    case WM_KEYUP:
        GameKey(&g_game, (UINT)wParam, FALSE, FALSE);
        return 0;
    case WM_KILLFOCUS:
        GameFocusLost(&g_game);
        return 0;
    case WM_SIZE:
        if (wParam == SIZE_MINIMIZED) GameFocusLost(&g_game);
        return 0;
    case WM_ERASEBKGND:
        /* 배경까지 백 버퍼에서 그리므로 기본 지우기를 생략하여 깜빡임을 방지합니다. */
        return 1;
    case WM_PAINT: {
        PAINTSTRUCT ps;
        HDC dc = BeginPaint(window, &ps);
        PaintGame(window, dc);
        EndPaint(window, &ps);
        return 0;
    }
    case WM_DESTROY:
        KillTimer(window, 1);
        PostQuitMessage(0);
        return 0;
    default:
        return DefWindowProcW(window, message, wParam, lParam);
    }
}

/* 유니코드 진입점입니다. /SUBSYSTEM:WINDOWS 설정으로 콘솔 창을 만들지 않습니다. */
int WINAPI wWinMain(HINSTANCE instance, HINSTANCE previous, PWSTR commandLine, int show)
{
    const wchar_t *className = L"SpaceGalagaWindow";
    WNDCLASSEXW wc = { 0 };
    /* 기본 클라이언트 영역을 기존 800x900의 150%인 1200x1350으로 요청합니다. */
    RECT rect = { 0, 0, GAME_WIDTH * 3 / 2, GAME_HEIGHT * 3 / 2 };
    HWND window;
    MSG message;
    int result;
    BOOL startMaximized = FALSE;
    UNREFERENCED_PARAMETER(previous);
    UNREFERENCED_PARAMETER(commandLine);
    SetProcessDPIAware();
    wc.cbSize = sizeof(wc);
    wc.lpfnWndProc = WindowProc;
    wc.hInstance = instance;
    wc.hCursor = LoadCursorW(NULL, IDC_ARROW);
    wc.hIcon = LoadIconW(NULL, IDI_APPLICATION);
    wc.lpszClassName = className;
    if (!RegisterClassExW(&wc)) return 1;
    AdjustWindowRectEx(&rect, WS_OVERLAPPEDWINDOW, FALSE, 0);
    /* 150% 창이 모니터보다 크면 처음부터 최대화합니다. 종전의 일률적인 90px
       여백과 세로 길이에 의한 이중 축소를 없애 사용 가능한 화면을 최대한 활용합니다. */
    {
        MONITORINFO monitor = { sizeof(MONITORINFO) };
        if (GetMonitorInfoW(MonitorFromPoint((POINT){0, 0}, MONITOR_DEFAULTTOPRIMARY), &monitor)) {
            int availableWidth = monitor.rcWork.right - monitor.rcWork.left;
            int availableHeight = monitor.rcWork.bottom - monitor.rcWork.top;
            if (rect.right - rect.left > availableWidth || rect.bottom - rect.top > availableHeight) {
                rect.left = rect.top = 0;
                rect.right = availableWidth;
                rect.bottom = availableHeight;
                startMaximized = TRUE;
            }
        }
    }
    window = CreateWindowExW(0, className, L"SPACE GALAGA | Win32 / C",
        WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT,
        rect.right - rect.left, rect.bottom - rect.top, NULL, NULL, instance, NULL);
    if (!window) {
        MessageBoxW(NULL, L"게임 창 또는 그리기 자원을 만들 수 없습니다.", L"실행 오류", MB_ICONERROR);
        result = 1;
    } else {
        ShowWindow(window, startMaximized ? SW_SHOWMAXIMIZED : show);
        UpdateWindow(window);
        /* GetMessage가 -1을 반환하는 오류도 구분하여 처리합니다. */
        while ((result = (int)GetMessageW(&message, NULL, 0, 0)) > 0) {
            TranslateMessage(&message);
            DispatchMessageW(&message);
        }
        result = result == -1 ? 1 : (int)message.wParam;
    }
    /* 선택된 비트맵은 원래 객체로 돌려놓은 뒤 삭제해야 GDI 자원이 누수되지 않습니다. */
    if (g_backDC && g_oldBitmap) SelectObject(g_backDC, g_oldBitmap);
    if (g_backBitmap) DeleteObject(g_backBitmap);
    if (g_backDC) DeleteDC(g_backDC);
    return result;
}
