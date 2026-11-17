/* 창을 생성하지 않고 공개 게임 API로 규칙을 검증하는 C 테스트입니다.
   Developer PowerShell에서 README의 명령으로 실행할 수 있습니다. */
#include "../Space_Galaga/game.h"
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

static Game game;
static const float step = 1.0f / 120.0f;

static void Reset(void)
{
    GameInit(&game);
    game.randomState = 12345;
    GameKey(&game, VK_RETURN, TRUE, FALSE);
    assert(game.mode == MODE_PLAY && game.lives == 3);
    assert(game.stage == 1 && game.enemyCount == 40);
}

int main(void)
{
    int i, j, count, sawBoss = 0;
    float x, y, elapsed;
    Reset();
    x = game.playerX; y = game.playerY;
    GameKey(&game, VK_RIGHT, TRUE, FALSE);
    GameKey(&game, VK_UP, TRUE, FALSE);
    GameUpdate(&game, step);
    assert(fabsf(sqrtf((game.playerX-x)*(game.playerX-x) +
        (game.playerY-y)*(game.playerY-y)) - 390 * step) < 0.01f);
    GameFocusLost(&game);
    assert(game.mode == MODE_PAUSE && !game.keys[VK_RIGHT] && !game.keys[VK_UP]);
    elapsed = game.time;
    GameUpdate(&game, 1);
    assert(game.time == elapsed);
    GameKey(&game, 'P', TRUE, FALSE);
    assert(game.mode == MODE_PLAY);
    GameKey(&game, 'P', TRUE, TRUE);
    assert(game.mode == MODE_PLAY); /* 키 반복으로 다시 정지하면 안 됩니다. */

    /* 강화 아이템 획득과 3방향 발사를 검증합니다. */
    Reset();
    game.items[0].active = 1;
    game.items[0].x = game.playerX; game.items[0].y = game.playerY;
    GameUpdate(&game, step);
    assert(game.powerTime == 12 && !game.items[0].active && game.score == 50);
    GameKey(&game, VK_SPACE, TRUE, FALSE);
    GameUpdate(&game, step);
    count = 0;
    for (i = 0; i < MAX_BULLETS; ++i) if (game.bullets[i].active && !game.bullets[i].enemy) ++count;
    assert(count == 3);

    /* 피격 후 무적, 목숨 소모, 게임 오버, 재시작을 검증합니다. */
    Reset();
    for (i = 0; i < 3; ++i) {
        Bullet *b = &game.bullets[0];
        game.invincibleTime = 0;
        b->active = 1; b->enemy = 1; b->radius = 5;
        b->x = game.playerX; b->y = game.playerY; b->vx = b->vy = 0;
        GameUpdate(&game, step);
        assert(game.lives == 2-i && game.invincibleTime > 2);
        if (i < 2) {
            b->active = 1; b->x = game.playerX; b->y = game.playerY;
            GameUpdate(&game, step);
            assert(game.lives == 2-i);
        }
    }
    assert(game.mode == MODE_OVER);
    game.bestScore = 9999;
    GameKey(&game, 'R', TRUE, FALSE);
    assert(game.mode == MODE_PLAY && game.lives == 3 && game.bestScore == 9999);

    /* 2체력 적은 두 발에 격파되고 적 수와 점수가 함께 갱신되어야 합니다. */
    Reset();
    memset(game.enemies, 0, sizeof(game.enemies));
    game.enemyCount = 1;
    game.enemies[0].active = 1; game.enemies[0].type = 2;
    game.enemies[0].hp = game.enemies[0].maxHp = 2;
    game.enemies[0].x = game.enemies[0].homeX = 400;
    game.enemies[0].y = game.enemies[0].homeY = 180;
    game.enemies[0].fireTime = 10;
    for (i = 0; i < 2; ++i) {
        Bullet *b = &game.bullets[0];
        b->active = 1; b->enemy = 0; b->radius = 4;
        b->x = game.enemies[0].x; b->y = game.enemies[0].y;
        b->vx = b->vy = 0;
        GameUpdate(&game, step);
        assert(game.enemies[0].hp == 1-i);
    }
    assert(game.enemyCount == 0 && game.score == 300 && game.bestScore == 300);
    game.waveDelay = 2.5f;
    GameUpdate(&game, step);
    assert(game.stage == 2 && game.enemyCount == 40);
    memset(game.enemies, 0, sizeof(game.enemies));
    game.stage = 4; game.enemyCount = 0; game.waveDelay = 2.5f;
    GameUpdate(&game, step);
    assert(game.stage == 5 && game.enemyCount == 1 && game.enemies[0].type == 3);

    /* 10분의 가상 플레이에서 배열 상태와 좌표가 유효한지 검사합니다.
       테스트에서는 무적을 유지하고 각 편대를 일정 시간 뒤 제거하여 보스까지 순회합니다. */
    Reset();
    for (i = 0; i < 72000; ++i) {
        game.invincibleTime = 1;
        game.keys[VK_SPACE] = TRUE;
        game.keys[VK_LEFT] = (i / 500) % 2 == 0;
        game.keys[VK_RIGHT] = !game.keys[VK_LEFT];
        if (i > 0 && i % 2400 == 0) {
            memset(game.enemies, 0, sizeof(game.enemies));
            game.enemyCount = 0;
        }
        GameUpdate(&game, step);
        assert(game.mode == MODE_PLAY && isfinite(game.playerX) && isfinite(game.playerY));
        assert(game.playerX >= 24 && game.playerX <= GAME_WIDTH-24);
        count = 0;
        for (j = 0; j < MAX_ENEMIES; ++j) {
            if (game.enemies[j].active) {
                ++count;
                assert(isfinite(game.enemies[j].x) && isfinite(game.enemies[j].y));
                if (game.enemies[j].type == 3) sawBoss = 1;
            }
        }
        assert(count == game.enemyCount);
    }
    assert(sawBoss && game.stage > 10);
    puts("PASS: movement, pause/focus, power-up, damage, restart, collision, waves, boss, 10-minute simulation");
    return 0;
}
