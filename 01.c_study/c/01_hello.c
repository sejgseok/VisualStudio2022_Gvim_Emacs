/* 01_hello.c: printf 출력, 변수와 자료형 크기, 반복문, 함수 */

#include <stdio.h>

static int
Square(int Value)
{
    int Result = Value*Value;
    return(Result);
}

int main(void)
{
    printf("Hello, C!\n");
    printf("안녕하세요. C 공부를 시작합니다.\n\n");

    int Count = 5;
    double Ratio = 2.5;
    char Grade = 'A';

    printf("int %d, double %.2f, char %c\n", Count, Ratio, Grade);
    printf("sizeof(int) = %zu, sizeof(double) = %zu, sizeof(void *) = %zu\n",
           sizeof(int), sizeof(double), sizeof(void *));
    printf("sizeof(\"한글\") = %zu (한글 한 글자 2바이트 + 끝의 0)\n\n", sizeof("한글"));

    for(int Index = 1; Index <= Count; ++Index)
    {
        printf("%d의 제곱 = %d\n", Index, Square(Index));
    }

    return(0);
}
