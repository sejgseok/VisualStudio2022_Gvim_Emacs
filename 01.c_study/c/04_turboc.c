/* 04_turboc.c: Turboc.h의 터보 C 스타일 함수 (clrscr, gotoxy, wherex, wherey,
   setcursortype, delay, randomize, random) */

/* Turboc.h는 이 폴더 맨 위(build.bat 옆)에 있다. build.bat이 그 폴더를 포함
   경로(-I)로 넘기므로 c\, cpp\ 어디에 있는 소스에서도 이렇게 쓴다. */
#include "Turboc.h"

int main(void)
{
    randomize();
    clrscr();
    setcursortype(NOCURSOR);

    gotoxy(2, 1);
    printf("Turboc.h 예제: 별 10개를 아무 곳에나 찍는다.");
    for(int Index = 0; Index < 10; ++Index)
    {
        gotoxy(2 + random(50), 3 + Index);
        printf("*  (%d, %d)", wherex(), wherey());
        delay(100);
    }

    gotoxy(2, 14);
    printf("아무 키나 누르면 끝난다.");
    int Key = getch();

    setcursortype(NORMALCURSOR);
    gotoxy(0, 16);
    printf("누른 키의 코드: %d\n", Key);
    return(0);
}
