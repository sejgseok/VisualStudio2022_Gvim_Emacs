

#if 1
#include <stdio.h>
#include <string.h> // strlen(str)
// 응용 실습 문제
// fibonacci 수열을 재귀 함수 이용하여 작성
int fibo(int* a, int n);
int display(int* a, int n);
int main(void)
{
    int a[100] = {1,1, };
    int n;

    scanf_s("%d", &n);
    fibo(a, n);
    display(a, n);

    return 0;
}
int fibo(int* a, int n)
{



}
int display(int* a, int n)
{
    int i;
        
    for (i = 0; i < n; i++)
    {
        printf("%4d", a[i]);
    }
    printf("\n");
}
#endif


#if 0
#include <stdio.h>
#include <string.h> // strlen(str)
// 응용 실습 문제
// fibonacci 수열비재귀 함수를 이용하여 작성
int fibo(int* a, int n);
int display(int* a, int n);
int main(void)
{
    int a[100] = {1,1, };
    int n;

    scanf_s("%d", &n);
    fibo(a, n);
    display(a, n);

    return(0);
}
int fibo(int* a, int n)
{
    int i;

    for (i = 2; i < n; i++)
    {
        a[i] = a[i-1] + a[i-2];
    }
}
int display(int* a, int n)
{
    int i;
        
    for (i = 0; i < n; i++)
    {
        printf("%4d", a[i]);
    }
    printf("\n");
}
#endif
#if 0
#include <stdio.h>
#include <string.h> // strlen(str)
// 응용 실습 문제
// strlen(str);
// 하나의 문장을 입력 받아 거꾸로 출력하는 함수 
// 예)  I am a student --> tneduts a ma I
// reverse() 함수 작성

void swap(char* a, char* b);
void reverse(char* str);
int main(void)
{
    char str[] = "I am a student";

    printf("[%s]\n", str);
    reverse(str);
    printf("[%s]\n", str);

    return(0);
}
void reverse(char* str)
{
    int i,j;

    for (i = 0, j = strlen(str)-1; i < j; i++, j--)
    {
        swap(str+i, str+j);
    }
}
void swap(char* a, char* b)
{
    char tmp;
    tmp = *a;
    *a = *b;
    *b = tmp;
}
#endif
#if 0
#include <stdio.h>
#include <string.h> // strlen(str)
// 응용 실습 문제
// strlen(str);
// 하나의 문장을 입력 받아 거꾸로 출력하는 함수 
// 예)  I am a student --> tneduts a ma I
// reverse() 함수 작성

void reverse(char* str);
int main(void)
{
    char str[100];

    gets(str);
    printf("[%s]\n", str);

    reverse(str);


    return(0);
}
void reverse(char* str)
{
    int i;
    int n;
    char tmp_str[100];

    n = strlen(str);
    for (i = 0; i < n; i++)
    {
        tmp_str[i] = str[n - 1 - i];
    }
    tmp_str[n] = '\0';
    printf("[%s]\n", tmp_str);
}
#endif

#if 0
#include <stdio.h>
#include <string.h> // strlen(str)
// 응용 실습 문제
// strlen(str);
//
int strindex(char* str);
int main(void)
{
    char str[] = "heloozod";
    int ret;

    ret = strindex(str);

    if (ret < 0)
        printf("t 를 찾을수 없습니다.\n");
    else
        printf("t의 index는 %d 입니다.\n", ret);

    return(0);
}
int strindex(char* str)
{
    int i;
    int n = strlen(str);

    for (i = 0; i < n; i++)
    {
        if (str[n-1-i] == 't')
            return n - 1 - i;
    }
    return -1;

}
#endif
#if 0
#include <stdio.h>
#include <string.h>
// 응용 실습 문제
// strlen(str);
//
int main(void)
{
    char str[] = "hellotod";
    int i;
    int len;
    int t_index;

    len = strlen(str);
    printf("str len = %d\n", len);

    for (i = len - 1; i >= 0; i--)
    {
        if (str[i] == 't')
            t_index = (len - 1) - i;
            //t_index = i; 
    }
    printf("t_index = %d\n", t_index);
    return(0);
}
#endif
#if 0
#include <stdio.h>
// 응용 실습 문제
//   'a' - 'A' = 32;  'A' - 'a' = -32
void my_toupper(char* str);
int main(void)
{
    char str[] = "hello world-!!";

    printf("[%s]\n", str);
    my_toupper(str);
    printf("[%s]\n", str);

    return(0);
}
void my_toupper(char* str)
{
    int i;
    for (i = 0; str[i]; i++)
    {
        if ( str[i] >= 'A' && str[i] <= 'z')
            str[i] -= 'a' - 'A'; // 32
    }
}
#endif
#if 0
#include <stdio.h>
// 응용 실습 문제
//   'a' - 'A' = 32;  'A' - 'a' = -32
void my_tolower(char* str);
int main(void)
{
    char str[] = "HELLO WORLD-!!";

    printf("[%s]\n", str);
    my_tolower(str);
    printf("[%s]\n", str);

    return(0);
}
void my_tolower(char* str)
{
    int i;
    for (i = 0; str[i]; i++)
    {
        if ( str[i] >= 'A' && str[i] <= 'z')
            str[i] += 'a' - 'A'; // 32
    }
}
#endif
#if 0
#include <stdio.h>
// 응용 실습 문제
//   'a' - 'A' = 32;  'A' - 'a' = -32
void my_tolower(char* str);
int main(void)
{
    char str[] = "HELLO WORLD";

    printf("[%s]\n", str);
    my_tolower(str);
    printf("[%s]\n", str);

    return(0);
}
void my_tolower(char* str)
{
    int i;
    for (i = 0; str[i]; i++)
    {
        if ( str[i] == ' ')
            continue;
        str[i] += 32; // 'a' - 'A';
    }
}
#endif
#if 0
#include <stdio.h>
// 응용 실습 문제
//   'a' - 'A' = 32;  'A' - 'a' = -32
void my_tolower(char* str);
int main(void)
{
    char str[] = "ABCDEFGLSF"; // 대문자 열을 소문자료 변환
    char *pstr = str;

    printf("str = %s\n", pstr);
    my_tolower(pstr);
    printf("str = %s\n", pstr);

    return(0);
}
void my_tolower(char* str)
{
    int i = 0;
    while ( *(str + i) != '\0') {
        *(str + i) += 32;
        i++;
    }
}
#endif
#if 0
#include <stdio.h>
// 응용 실습 문제
//   'a' - 'A' = 32;  'A' - 'a' = -32
int main(void)
{
    char str[] = "ABCDEFGLSF"; // 대문자 열을 소문자료 변환
    int i = 0;
    char *pstr = str;

    printf("str = %s\n", pstr);
    while ( pstr[i] != '\0') {
        pstr[i] += 32;
        i++;
    }
    printf("str = %s\n", pstr);

    return(0);
}
#endif
#if 0
#include <stdio.h>
void gugudan(int(*a)[9]);
void display(int(*a)[9]);
int main(void)
{
    int a[9][9];

    gugudan(a);
    display(a);

    return(0);
}
void gugudan(int(*a)[9])
{
    int i,j;

    for (i = 0; i < 9; i++)
    {
        for (j = 0; j < 9; j++)
        {
            a[i][j] = (i+1) * (j+1);
        }
    }
}
void display(int(*a)[9])
{
    int i, j;

    for (i = 0; i < 9; i++)
    {
        for (j = 0; j < 9; j++)
        {
            printf("%4d * %4d = %4d\n", i+1, j+1, a[i][j]);
        }
        printf("===================\n");
    }
}
#endif
#if 0
#include <stdio.h>
void gugudan(int (*a)[9]);
int main(void)
{
    int arr[9][9];

    gugudan(arr);

    return(0);
}
void gugudan(int (*a)[9])
{
    int i, j;

    for (i = 0; i < 9 ; i++)
    {
        for (j = 0; j < 9; j++)
        {
            a[i][j] =(i+1)*(j+1);
        }
    }
    for (i = 0; i < 9; i++)
    {
        for (j = 0; j < 9; j++)
        {
            printf("%d X %d = %d\n", i+1, j+1, a[i][j]);
        }
        printf("=================\n");
    }
}
#endif

#if 0
#include <stdio.h>

int main(void)
{

    return(0);
}
#endif
