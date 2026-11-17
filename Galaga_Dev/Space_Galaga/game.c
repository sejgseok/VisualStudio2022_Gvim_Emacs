/* game.c - 이동, 공격, 충돌, 스테이지 진행과 GDI 렌더링을 구현합니다.
   모든 시간 값은 초, 위치는 800 x 900 논리 화면의 픽셀 단위입니다. */
#include "game.h"
#include <math.h>
#include <stdio.h>
#include <string.h>

#define PI_F 3.141592654f
#define RGB_BG RGB(5, 9, 24)
#define CYAN RGB(72, 229, 255)
#define GOLD RGB(255, 211, 89)

static float Clamp(float v, float low, float high)
{
    return v < low ? low : (v > high ? high : v);
}

/* 게임 전용 난수 상태를 사용합니다. 전역 rand()에 의존하지 않으며 0~1을 반환합니다. */
static float Random01(Game *g)
{
    g->randomState = g->randomState * 1664525u + 1013904223u;
    return (float)((g->randomState >> 8) & 0xFFFFFFu) / 16777216.0f;
}

/* 원형 충돌은 제곱 거리로 비교하여 매번 제곱근을 계산하지 않습니다. */
static int Hit(float ax, float ay, float bx, float by, float radius)
{
    float dx = ax - bx, dy = ay - by;
    return dx * dx + dy * dy < radius * radius;
}

static void Burst(Game *g, float x, float y, COLORREF color, int count)
{
    int i;
    for (i = 0; i < MAX_PARTICLES && count > 0; ++i) {
        Particle *p = &g->particles[i];
        if (!p->active) {
            float angle = Random01(g) * PI_F * 2.0f;
            float speed = 40.0f + Random01(g) * 190.0f;
            p->active = 1; p->x = x; p->y = y;
            p->vx = cosf(angle) * speed; p->vy = sinf(angle) * speed;
            p->life = p->maxLife = 0.25f + Random01(g) * 0.6f;
            p->color = color;
            --count;
        }
    }
}

/* 비활성 탄환 슬롯을 재사용합니다. 배열이 가득 차면 해당 발사만 생략합니다. */
static void Shoot(Game *g, float x, float y, float vx, float vy, int enemy)
{
    int i;
    for (i = 0; i < MAX_BULLETS; ++i) {
        Bullet *b = &g->bullets[i];
        if (!b->active) {
            b->active = 1; b->enemy = enemy;
            b->x = x; b->y = y; b->vx = vx; b->vy = vy;
            b->radius = enemy ? 5.0f : 4.0f;
            return;
        }
    }
}

/* 기본 편대는 8열 5행입니다. 5의 배수 스테이지에는 큰 보스 한 기가 등장합니다.
   난이도는 상한을 두어 장시간 플레이해도 발사 간격이 음수가 되지 않습니다. */
static void SpawnWave(Game *g)
{
    int row, column;
    memset(g->enemies, 0, sizeof(g->enemies));
    memset(g->bullets, 0, sizeof(g->bullets));
    ++g->stage;
    g->waveDelay = 0;
    if (g->stage % 5 == 0) {
        Enemy *e = &g->enemies[0];
        e->active = 1; e->type = 3;
        e->hp = e->maxHp = 65 + g->stage * 3;
        e->x = e->homeX = GAME_WIDTH / 2.0f;
        e->y = e->homeY = 185;
        e->fireTime = 1.5f;
        g->enemyCount = 1;
        return;
    }
    g->enemyCount = 40;
    for (row = 0; row < 5; ++row) {
        for (column = 0; column < 8; ++column) {
            Enemy *e = &g->enemies[row * 8 + column];
            e->active = 1;
            e->type = row == 0 ? 2 : (row < 3 ? 1 : 0);
            e->hp = e->maxHp = e->type == 2 ? 2 : 1;
            e->x = e->homeX = 120.0f + (float)column * 80;
            e->homeY = 165.0f + (float)row * 58;
            e->y = -100.0f - (float)row * 55;
            e->time = (float)column * 0.2f;
            e->fireTime = 1.5f + Random01(g) * 7;
        }
    }
}

static void StartGame(Game *g)
{
    /* 최고 점수와 배경 별은 재시작할 때 유지합니다. 최고 점수는 실행 중에만 보관합니다. */
    memset(g->bullets, 0, sizeof(g->bullets));
    memset(g->particles, 0, sizeof(g->particles));
    memset(g->items, 0, sizeof(g->items));
    memset(g->keys, 0, sizeof(g->keys));
    g->score = 0; g->lives = 3; g->stage = 0; g->kills = 0;
    g->playerX = GAME_WIDTH / 2.0f; g->playerY = GAME_HEIGHT - 130.0f;
    g->shotTime = 0; g->invincibleTime = 2; g->powerTime = 0;
    g->time = 0; g->flashTime = 0;
    g->mode = MODE_PLAY;
    SpawnWave(g);
}

void GameInit(Game *g)
{
    int i;
    memset(g, 0, sizeof(*g));
    g->randomState = GetTickCount() | 1u;
    g->mode = MODE_TITLE;
    for (i = 0; i < MAX_STARS; ++i) {
        Star *s = &g->stars[i];
        s->x = Random01(g) * GAME_WIDTH;
        s->y = Random01(g) * GAME_HEIGHT;
        s->speed = 20 + Random01(g) * 100;
        s->size = s->speed > 85 ? 2.0f : 1.0f;
    }
}

void GameKey(Game *g, UINT key, BOOL down, BOOL repeat)
{
    if (key < 256) g->keys[key] = down;
    if (!down || repeat) return;
    if (key == VK_RETURN && (g->mode == MODE_TITLE || g->mode == MODE_OVER)) StartGame(g);
    else if (key == 'P' && g->mode == MODE_PLAY) g->mode = MODE_PAUSE;
    else if (key == 'P' && g->mode == MODE_PAUSE) g->mode = MODE_PLAY;
    else if (key == 'R' && g->mode == MODE_OVER) StartGame(g);
}

void GameFocusLost(Game *g)
{
    /* Alt+Tab 중 키를 놓으면 WM_KEYUP이 오지 않을 수 있으므로 입력을 모두 해제합니다. */
    memset(g->keys, 0, sizeof(g->keys));
    if (g->mode == MODE_PLAY) g->mode = MODE_PAUSE;
}

static void DamagePlayer(Game *g)
{
    int i;
    if (g->invincibleTime > 0 || g->mode != MODE_PLAY) return;
    Burst(g, g->playerX, g->playerY, CYAN, 45);
    --g->lives;
    g->powerTime = 0; g->invincibleTime = 2.5f; g->flashTime = 0.18f;
    /* 피격 직후 화면에 남은 적 탄환을 없애 연속 피격을 방지합니다. */
    for (i = 0; i < MAX_BULLETS; ++i)
        if (g->bullets[i].enemy) g->bullets[i].active = 0;
    if (g->lives <= 0) g->mode = MODE_OVER;
}

static void DestroyEnemy(Game *g, Enemy *e)
{
    int i;
    e->active = 0;
    --g->enemyCount; ++g->kills;
    g->score += e->type == 3 ? 3000 : (e->type + 1) * (e->diving ? 150 : 100);
    if (g->score > g->bestScore) g->bestScore = g->score;
    Burst(g, e->x, e->y, e->type == 3 ? GOLD : RGB(255, 117, 93), e->type == 3 ? 100 : 22);
    /* 7기마다 강화 아이템을 확정 지급하여 난수 운에 관계없이 강화 기회를 줍니다. */
    if (g->kills % 7 == 0 || e->type == 3) {
        for (i = 0; i < MAX_ITEMS; ++i) {
            if (!g->items[i].active) {
                g->items[i].active = 1;
                g->items[i].x = e->x; g->items[i].y = e->y;
                break;
            }
        }
    }
}

static void UpdateEnemies(Game *g, float dt)
{
    int i;
    float difficulty = Clamp((float)g->stage, 1, 16);
    for (i = 0; i < MAX_ENEMIES; ++i) {
        Enemy *e = &g->enemies[i];
        if (!e->active) continue;
        e->time += dt;
        if (e->type == 3) {
            e->x = 400 + sinf(e->time * 0.8f) * 245;
            e->y = 185 + sinf(e->time * 1.6f) * 38;
        } else if (e->diving) {
            e->diveTime += dt;
            e->y += (170 + difficulty * 9) * dt;
            e->x += sinf(e->diveTime * 3.0f + (float)i) * 200 * dt;
            e->x = Clamp(e->x, 28, GAME_WIDTH - 28.0f);
            if (e->y > GAME_HEIGHT + 30) {
                e->diving = 0; e->y = -45;
            }
        } else {
            float targetY = e->homeY + sinf(g->time * 1.5f + (float)i * 0.1f) * 8;
            e->x = e->homeX + sinf(g->time * 1.2f) * 42;
            e->y += (targetY - e->y) * Clamp(dt * 3, 0, 1);
            /* 시간에 비례한 확률을 사용하므로 업데이트 빈도가 바뀌어도 비슷한 빈도로 급강하합니다. */
            if (g->time > 2.5f && Random01(g) < dt * (0.013f + difficulty * 0.003f)) {
                e->diving = 1; e->diveTime = 0;
            }
        }
        e->fireTime -= dt;
        if (e->fireTime <= 0 && e->y > 60 && e->y < g->playerY - 50) {
            float dx = g->playerX - e->x, dy = g->playerY - e->y;
            float length = sqrtf(dx * dx + dy * dy);
            float speed = 190 + difficulty * 9;
            if (length < 1) length = 1;
            Shoot(g, e->x, e->y + 20, dx / length * speed, dy / length * speed, 1);
            if (e->type == 3) {
                int k;
                for (k = -2; k <= 2; ++k)
                    Shoot(g, e->x, e->y + 35, (float)k * 85, 235 + difficulty * 5, 1);
                e->fireTime = Clamp(1.2f - difficulty * 0.03f, 0.55f, 1.2f);
            } else e->fireTime = 3 + Random01(g) * 6 - difficulty * 0.09f;
        }
        if (Hit(e->x, e->y, g->playerX, g->playerY, e->type == 3 ? 65.0f : 27.0f))
            DamagePlayer(g);
    }
}

void GameUpdate(Game *g, float dt)
{
    int i, j;
    float dx, dy, length;
    if (g->mode == MODE_PAUSE) return;
    /* 별과 폭발은 타이틀 및 게임 오버 화면에서도 계속 움직입니다. */
    for (i = 0; i < MAX_STARS; ++i) {
        Star *s = &g->stars[i];
        s->y += s->speed * dt;
        if (s->y > GAME_HEIGHT) { s->y = 0; s->x = Random01(g) * GAME_WIDTH; }
    }
    for (i = 0; i < MAX_PARTICLES; ++i) {
        Particle *p = &g->particles[i];
        if (!p->active) continue;
        p->life -= dt; p->x += p->vx * dt; p->y += p->vy * dt;
        if (p->life <= 0) p->active = 0;
    }
    if (g->mode != MODE_PLAY) return;
    g->time += dt;
    g->invincibleTime = Clamp(g->invincibleTime - dt, 0, 10);
    g->powerTime = Clamp(g->powerTime - dt, 0, 20);
    g->flashTime = Clamp(g->flashTime - dt, 0, 1);
    dx = (float)((g->keys[VK_RIGHT] || g->keys['D']) - (g->keys[VK_LEFT] || g->keys['A']));
    dy = (float)((g->keys[VK_DOWN] || g->keys['S']) - (g->keys[VK_UP] || g->keys['W']));
    length = sqrtf(dx * dx + dy * dy);
    /* 대각선 입력도 직선 이동과 같은 속도가 되도록 방향 벡터를 정규화합니다. */
    if (length > 0) {
        float speed = g->keys[VK_SHIFT] ? 190.0f : 390.0f;
        /* 커진 날개와 하단 안내 패널이 겹치지 않도록 화면 가장자리 여백도 늘립니다. */
        g->playerX = Clamp(g->playerX + dx / length * speed * dt, 36, GAME_WIDTH - 36.0f);
        g->playerY = Clamp(g->playerY + dy / length * speed * dt, 460, GAME_HEIGHT - 120.0f);
    }
    g->shotTime -= dt;
    if (g->keys[VK_SPACE] && g->shotTime <= 0) {
        Shoot(g, g->playerX, g->playerY - 22, 0, -680, 0);
        if (g->powerTime > 0) {
            Shoot(g, g->playerX - 12, g->playerY - 10, -140, -650, 0);
            Shoot(g, g->playerX + 12, g->playerY - 10, 140, -650, 0);
        }
        g->shotTime = g->powerTime > 0 ? 0.12f : 0.17f;
    }
    UpdateEnemies(g, dt);
    if (g->mode != MODE_PLAY) return;
    for (i = 0; i < MAX_BULLETS; ++i) {
        Bullet *b = &g->bullets[i];
        if (!b->active) continue;
        b->x += b->vx * dt; b->y += b->vy * dt;
        if (b->x < -20 || b->x > GAME_WIDTH + 20 || b->y < -20 || b->y > GAME_HEIGHT + 20) {
            b->active = 0; continue;
        }
        if (b->enemy) {
            /* 플레이어 피격 원은 그림보다 작게 만들어 탄막 회피에 여유를 줍니다. */
            if (Hit(b->x, b->y, g->playerX, g->playerY, 10 + b->radius) && g->invincibleTime <= 0) {
                b->active = 0; DamagePlayer(g);
                if (g->mode != MODE_PLAY) return;
            }
        } else {
            for (j = 0; j < MAX_ENEMIES; ++j) {
                Enemy *e = &g->enemies[j];
                if (e->active && Hit(b->x, b->y, e->x, e->y, e->type == 3 ? 54.0f : 23.0f)) {
                    b->active = 0; --e->hp;
                    Burst(g, b->x, b->y, GOLD, 4);
                    if (e->hp <= 0) DestroyEnemy(g, e);
                    break;
                }
            }
        }
    }
    for (i = 0; i < MAX_ITEMS; ++i) {
        Item *item = &g->items[i];
        if (!item->active) continue;
        item->y += 115 * dt;
        if (Hit(item->x, item->y, g->playerX, g->playerY, 32)) {
            item->active = 0; g->powerTime = 12;
            g->score += 50;
            if (g->score > g->bestScore) g->bestScore = g->score;
            Burst(g, item->x, item->y, CYAN, 18);
        } else if (item->y > GAME_HEIGHT + 20) item->active = 0;
    }
    if (g->enemyCount == 0) {
        g->waveDelay += dt;
        if (g->waveDelay > 2.5f) SpawnWave(g);
    }
}

/* 아래 함수들은 GDI 기본 도형만 사용합니다. 만든 펜/브러시는 원래 선택 객체를
   복구한 뒤 반드시 삭제하며, 운영체제 제공 스톡 객체는 삭제하지 않습니다. */
static void Box(HDC dc, int x, int y, int w, int h, COLORREF color)
{
    RECT r = { x, y, x + w, y + h };
    HBRUSH brush = CreateSolidBrush(color);
    FillRect(dc, &r, brush);
    DeleteObject(brush);
}

static void Oval(HDC dc, int x, int y, int w, int h, COLORREF color)
{
    HBRUSH brush = CreateSolidBrush(color);
    HGDIOBJ oldBrush = SelectObject(dc, brush);
    HGDIOBJ oldPen = SelectObject(dc, GetStockObject(NULL_PEN));
    Ellipse(dc, x, y, x + w, y + h);
    SelectObject(dc, oldPen); SelectObject(dc, oldBrush);
    DeleteObject(brush);
}

static void Shape(HDC dc, POINT *points, int count, COLORREF color)
{
    HBRUSH brush = CreateSolidBrush(color);
    HGDIOBJ oldBrush = SelectObject(dc, brush);
    HGDIOBJ oldPen = SelectObject(dc, GetStockObject(NULL_PEN));
    Polygon(dc, points, count);
    SelectObject(dc, oldPen); SelectObject(dc, oldBrush);
    DeleteObject(brush);
}

/* 글꼴은 프레임 안에서 재사용하고 프레임 종료 시 해제합니다. 한글은 맑은 고딕으로 표시합니다. */
static void Label(HDC dc, HFONT font, int x, int y, int width, const wchar_t *text, COLORREF color, UINT align)
{
    RECT r = { x, y, x + width, y + 120 };
    HGDIOBJ old = SelectObject(dc, font);
    SetTextColor(dc, color);
    DrawTextW(dc, text, -1, &r, DT_TOP | DT_SINGLELINE | DT_NOPREFIX | align);
    SelectObject(dc, old);
}

static void DrawShip(HDC dc, int x, int y, float time, int powered)
{
    /* 중심점은 그대로 두고 도형만 1.5배 확대합니다. SaveDC/RestoreDC로
       변환이 다음 적이나 텍스트에 누적되지 않게 원래 좌표계를 복구합니다. */
    int saved = SaveDC(dc);
    XFORM scale = { 1.5f, 0, 0, 1.5f, -0.5f * (float)x, -0.5f * (float)y };
    POINT body[] = { {x,y-25}, {x+8,y-5}, {x+22,y+14}, {x+22,y+22},
        {x+6,y+15}, {x,y+20}, {x-6,y+15}, {x-22,y+22}, {x-22,y+14}, {x-8,y-5} };
    int flame = 10 + (int)((sinf(time * 40) + 1) * 5);
    SetGraphicsMode(dc, GM_ADVANCED);
    SetWorldTransform(dc, &scale);
    Box(dc, x - 4, y + 17, 8, flame, GOLD);
    Box(dc, x - 2, y + 17, 4, flame - 3, RGB(255, 250, 220));
    Shape(dc, body, 10, RGB(222, 241, 255));
    Box(dc, x - 4, y - 7, 8, 17, CYAN);
    Box(dc, x - 20, y + 12, 8, 6, powered ? GOLD : RGB(244, 76, 110));
    Box(dc, x + 12, y + 12, 8, 6, powered ? GOLD : RGB(244, 76, 110));
    RestoreDC(dc, saved);
}

static void DrawEnemy(HDC dc, const Enemy *e)
{
    int x = (int)e->x, y = (int)e->y;
    int saved = SaveDC(dc);
    XFORM scale = { 1.5f, 0, 0, 1.5f, -0.5f * (float)x, -0.5f * (float)y };
    COLORREF color = e->type == 0 ? RGB(105, 126, 255) : (e->type == 1 ? RGB(255, 95, 151) : GOLD);
    /* 적과 보스도 150%로 표시합니다. 충돌 원은 유지하여 회피 난이도를 보존합니다. */
    SetGraphicsMode(dc, GM_ADVANCED);
    SetWorldTransform(dc, &scale);
    if (e->type == 3) {
        POINT wings[] = { {x-70,y+20}, {x-58,y-20}, {x-20,y-5}, {x,y-38},
            {x+20,y-5}, {x+58,y-20}, {x+70,y+20}, {x+25,y+30}, {x-25,y+30} };
        Shape(dc, wings, 9, RGB(161, 94, 241));
        Oval(dc, x - 25, y - 24, 50, 55, RGB(239, 123, 188));
        Oval(dc, x - 12, y - 7, 24, 24, GOLD);
        Box(dc, x - 23, y - 48, 46, 5, RGB(45, 38, 65));
        Box(dc, x - 23, y - 48, (int)(46.0f * (float)e->hp / (float)e->maxHp), 5, GOLD);
    } else {
        int flap = (int)(sinf(e->time * 10) * 7);
        POINT wings[] = { {x-7,y-9}, {x-25,y-19+flap}, {x-20,y+14},
            {x,y+5}, {x+20,y+14}, {x+25,y-19+flap}, {x+7,y-9} };
        Shape(dc, wings, 7, color);
        Oval(dc, x - 10, y - 17, 20, 32, e->hp > 1 ? RGB(100, 236, 163) : color);
        Box(dc, x - 6, y - 7, 4, 6, RGB_BG);
        Box(dc, x + 2, y - 7, 4, 6, RGB_BG);
    }
    RestoreDC(dc, saved);
}

void GameDraw(const Game *g, HDC dc)
{
    int i;
    wchar_t text[128];
    /* 기존 18 / 25 / 57px 글꼴을 약 150%인 27 / 38 / 86px로 확대합니다.
       패널과 줄 간격도 아래에서 함께 늘려 확대된 한글이 잘리지 않게 배치합니다. */
    HFONT smallFont = CreateFontW(27, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
        HANGUL_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY, DEFAULT_PITCH, L"맑은 고딕");
    HFONT mediumFont = CreateFontW(38, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE,
        HANGUL_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY, DEFAULT_PITCH, L"맑은 고딕");
    HFONT largeFont = CreateFontW(86, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE,
        HANGUL_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY, DEFAULT_PITCH, L"맑은 고딕");
    SetBkMode(dc, TRANSPARENT);
    Box(dc, 0, 0, GAME_WIDTH, GAME_HEIGHT, RGB_BG);
    for (i = 0; i < MAX_STARS; ++i) {
        const Star *s = &g->stars[i];
        int brightness = (int)(85 + s->speed);
        Box(dc, (int)s->x, (int)s->y, (int)s->size, (int)s->size,
            RGB(brightness - 30, brightness - 15, brightness));
    }
    if (g->mode != MODE_TITLE) {
        for (i = 0; i < MAX_ENEMIES; ++i)
            if (g->enemies[i].active) DrawEnemy(dc, &g->enemies[i]);
        for (i = 0; i < MAX_BULLETS; ++i) {
            const Bullet *b = &g->bullets[i];
            if (!b->active) continue;
            if (b->enemy) {
                Oval(dc, (int)b->x - 7, (int)b->y - 7, 15, 15, RGB(255, 95, 125));
                Oval(dc, (int)b->x - 3, (int)b->y - 3, 6, 6, RGB(255, 230, 190));
            } else {
                Box(dc, (int)b->x - 3, (int)b->y - 15, 6, 30, CYAN);
                Box(dc, (int)b->x - 1, (int)b->y - 12, 3, 18, RGB(240, 255, 255));
            }
        }
        for (i = 0; i < MAX_ITEMS; ++i) {
            const Item *item = &g->items[i];
            if (!item->active) continue;
            Oval(dc, (int)item->x - 22, (int)item->y - 22, 45, 45, RGB(17, 90, 113));
            Label(dc, smallFont, (int)item->x - 22, (int)item->y - 20, 45, L"P", CYAN, DT_CENTER);
        }
        if (g->mode != MODE_OVER && (g->invincibleTime <= 0 || (int)(g->invincibleTime * 10) % 2 == 0))
            DrawShip(dc, (int)g->playerX, (int)g->playerY, g->time, g->powerTime > 0);
    }
    for (i = 0; i < MAX_PARTICLES; ++i) {
        const Particle *p = &g->particles[i];
        if (p->active) {
            float fade = p->life / p->maxLife;
            COLORREF c = RGB((int)(GetRValue(p->color) * fade),
                (int)(GetGValue(p->color) * fade), (int)(GetBValue(p->color) * fade));
            Box(dc, (int)p->x - 2, (int)p->y - 2, 4, 4, c);
        }
    }
    /* HUD는 적과 탄환 위에 그려 정보가 가려지지 않게 합니다. */
    Box(dc, 0, 0, GAME_WIDTH, 112, RGB(10, 18, 37));
    Box(dc, 0, 111, GAME_WIDTH, 1, RGB(38, 61, 88));
    swprintf_s(text, _countof(text), L"SCORE  %06d", g->score);
    Label(dc, mediumFont, 20, 12, 330, text, CYAN, DT_LEFT);
    swprintf_s(text, _countof(text), L"BEST  %06d", g->bestScore);
    Label(dc, smallFont, 20, 64, 330, text, RGB(147, 167, 196), DT_LEFT);
    swprintf_s(text, _countof(text), L"STAGE  %02d", g->stage);
    Label(dc, mediumFont, 340, 30, 240, text, GOLD, DT_CENTER);
    swprintf_s(text, _countof(text), L"LIFE  %d", g->lives);
    Label(dc, mediumFont, 580, 12, 200, text, RGB(255, 135, 167), DT_RIGHT);
    if (g->powerTime > 0) {
        swprintf_s(text, _countof(text), L"3-WAY  %.1f s", (double)g->powerTime);
        Label(dc, smallFont, 550, 64, 230, text, CYAN, DT_RIGHT);
    }
    /* 커진 조작 안내를 두 줄로 나누어 좁은 창에서도 글자가 서로 겹치지 않습니다. */
    Box(dc, 0, 820, GAME_WIDTH, 80, RGB(10, 18, 37));
    Label(dc, smallFont, 0, 825, GAME_WIDTH, L"방향키 / WASD 이동    SPACE 발사", RGB(175, 192, 215), DT_CENTER);
    Label(dc, smallFont, 0, 861, GAME_WIDTH, L"SHIFT 정밀 이동    P 일시정지    F11 전체 화면", RGB(175, 192, 215), DT_CENTER);
    if (g->mode == MODE_TITLE) {
        Label(dc, smallFont, 0, 175, GAME_WIDTH, L"W I N 3 2   A R C A D E", CYAN, DT_CENTER);
        Label(dc, largeFont, 0, 235, GAME_WIDTH, L"SPACE GALAGA", RGB(235, 244, 255), DT_CENTER);
        Label(dc, mediumFont, 0, 345, GAME_WIDTH, L"별의 바다를 지켜라", GOLD, DT_CENTER);
        DrawShip(dc, 400, 460, 0, 1);
        Label(dc, mediumFont, 0, 565, GAME_WIDTH, L"ENTER 키를 눌러 출격", CYAN, DT_CENTER);
        Label(dc, smallFont, 0, 635, GAME_WIDTH, L"적 편대 격파 · 급강하 회피 · 5스테이지마다 보스", RGB(175, 190, 212), DT_CENTER);
        Label(dc, smallFont, 0, 685, GAME_WIDTH, L"P 아이템 획득 시 12초간 3방향 강화 사격", RGB(175, 190, 212), DT_CENTER);
        Label(dc, smallFont, 0, 755, GAME_WIDTH, L"순수 C + Windows API / GDI  |  ESC 종료", RGB(147, 167, 196), DT_CENTER);
    } else if (g->mode == MODE_PAUSE || g->mode == MODE_OVER) {
        Box(dc, 40, 285, 720, 350, RGB(14, 27, 49));
        Box(dc, 40, 285, 720, 4, CYAN);
        Label(dc, largeFont, 40, 310, 720, g->mode == MODE_PAUSE ? L"PAUSED" : L"GAME OVER", RGB(238, 245, 255), DT_CENTER);
        if (g->mode == MODE_OVER) {
            swprintf_s(text, _countof(text), L"최종 점수 %d", g->score);
            Label(dc, mediumFont, 40, 420, 720, text, GOLD, DT_CENTER);
            swprintf_s(text, _countof(text), L"도달 스테이지 %d", g->stage);
            Label(dc, mediumFont, 40, 470, 720, text, GOLD, DT_CENTER);
        } else Label(dc, smallFont, 40, 445, 720, L"창 전환 시에도 자동으로 일시정지합니다.", GOLD, DT_CENTER);
        Label(dc, mediumFont, 40, 560, 720, g->mode == MODE_PAUSE ? L"P 키로 계속하기" : L"ENTER / R 다시 시작", CYAN, DT_CENTER);
    } else if (g->enemyCount == 0) {
        Label(dc, largeFont, 0, 390, GAME_WIDTH, L"STAGE CLEAR", GOLD, DT_CENTER);
        Label(dc, mediumFont, 0, 500, GAME_WIDTH, L"다음 편대가 접근합니다", CYAN, DT_CENTER);
    }
    if (g->flashTime > 0 && g->mode == MODE_PLAY) {
        Box(dc, 0, 112, 8, 708, RGB(255, 94, 115));
        Box(dc, GAME_WIDTH - 8, 112, 8, 708, RGB(255, 94, 115));
    }
    DeleteObject(smallFont); DeleteObject(mediumFont); DeleteObject(largeFont);
}
