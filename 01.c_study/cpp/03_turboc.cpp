// 03_turboc.cpp: C++ 소스에서 Turboc.h 쓰기 (kbhit, getch, gotoxy, random, delay)

#include <iostream>
#include <string>

#include "Turboc.h"

int
main()
{
    randomize();
    clrscr();

    std::string Title = "Turboc.h C++ 예제: 아무 키나 누르면 멈춘다.";
    gotoxy(2, 1);
    std::cout << Title << std::flush;

    int Count = 0;
    while(!kbhit() && Count < 50) // 키를 누르거나 5초가 지나면 끝난다
    {
        gotoxy(2 + random(60), 3 + random(10));
        std::cout << '#' << std::flush;
        delay(100);
        ++Count;
    }
    if(kbhit())
    {
        getch(); // 누른 키를 읽어서 버린다
    }

    gotoxy(0, 14);
    std::cout << "찍은 # 개수: " << Count << "\n";
    return(0);
}
