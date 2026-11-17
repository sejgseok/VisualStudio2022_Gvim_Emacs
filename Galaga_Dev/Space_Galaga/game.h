/* game.h - 게임의 자료 구조와 Win32 창에서 호출할 공개 함수입니다. */
#ifndef SPACE_GALAGA_GAME_H
#define SPACE_GALAGA_GAME_H

#include <windows.h>

/* 창 크기와 무관하게 충돌 판정과 그리기는 이 논리 해상도를 사용합니다. */
#define GAME_WIDTH 800
#define GAME_HEIGHT 900
#define MAX_ENEMIES 48
#define MAX_BULLETS 256
#define MAX_PARTICLES 320
#define MAX_STARS 100
#define MAX_ITEMS 12

typedef enum GameMode { MODE_TITLE, MODE_PLAY, MODE_PAUSE, MODE_OVER } GameMode;

typedef struct Bullet {
    /* enemy가 0이면 플레이어 탄환, 1이면 적 탄환입니다. radius는 충돌 반지름입니다. */
    int active, enemy;
    /* vx/vy는 초당 이동량입니다. 다음 위치 = 현재 위치 + 속도 * dt 입니다. */
    float x, y, vx, vy, radius;
} Bullet;

typedef struct Enemy {
    /* type: 0 일반, 1 중급, 2 장갑, 3 보스. hp가 0이면 격파 처리합니다. */
    int active, type, hp, maxHp, diving;
    /* homeX/homeY는 편대 복귀 지점, diveTime은 급강하 궤적 계산용 누적 시간,
       fireTime은 다음 조준 발사까지 남은 시간입니다. */
    float x, y, homeX, homeY, time, diveTime, fireTime;
} Enemy;

typedef struct Particle {
    int active;
    /* 남은 life / 초기 maxLife 비율로 색을 어둡게 하여 자연스럽게 사라지게 합니다. */
    float x, y, vx, vy, life, maxLife;
    COLORREF color;
} Particle;

typedef struct Star { float x, y, speed, size; } Star;
typedef struct Item { int active; float x, y; } Item;

/* 배열을 고정 크기로 두어 플레이 중 동적 메모리 할당이 필요 없습니다.
   키 배열은 WM_KEYDOWN/WM_KEYUP에서 갱신하며 실제 이동은 고정 시간 간격으로 수행합니다. */
typedef struct Game {
    GameMode mode;
    BOOL keys[256];
    unsigned int randomState;
    /* kills는 아이템 지급 주기 계산용이며, enemyCount는 스테이지 종료 판정용입니다. */
    int score, bestScore, lives, stage, enemyCount, kills;
    /* shotTime: 발사 대기 / invincibleTime: 무적 / powerTime: 강화 효과 잔여 시간 */
    float playerX, playerY, shotTime, invincibleTime, powerTime;
    /* time: 진행 시간 / waveDelay: 편대 전멸 후 대기 / flashTime: 피격 테두리 효과 */
    float time, waveDelay, flashTime;
    Bullet bullets[MAX_BULLETS];
    Enemy enemies[MAX_ENEMIES];
    Particle particles[MAX_PARTICLES];
    Star stars[MAX_STARS];
    Item items[MAX_ITEMS];
} Game;

void GameInit(Game *game);
void GameKey(Game *game, UINT key, BOOL down, BOOL repeat);
void GameFocusLost(Game *game);
void GameUpdate(Game *game, float dt);
void GameDraw(const Game *game, HDC dc);

#endif
