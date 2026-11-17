
#if 1
#include <stdio.h>
// 구구단 프로그램 
void gugudan(int *(a)[9]);

int main(void)
{
    //int sum = 0;
    int a[9][9];
    
    gugudan((*a)[9]);

    return(0);
}
void gugudan(int *(a)[9])
{
    int i, j;
    for (i = 1; i <= 9; i++)
    {
        for (j = 1; j <= 9; j++)
        {
            printf("%d X %d = %d\n", i, j, a[i][j] = i*j);
        }
        printf("=============\n");
    }
}


#endif


#if 0
#include <stdio.h>
// 10 과 20 입력할 경우 

int main(void)
{
    int fahren; // 섭씨 celsius  fahren  
    double celsius; // 섭씨 celsius  fahren  

    scanf_s("%d", &fahren);

    celsius = (5./9)*(fahren - 32);

    printf("celsius = %.2lf\n", celsius);

    return(0);
}
#endif
#if 0
#include <stdio.h>
// 10 과 20 입력할 경우 
// (1+2+3+..+10)+(1+2+3+..+10+11)+(1+2+3+..+10+11+12)+(1+2+3+..+10+11+12)+
// +(1+2+3+..+10+11+12+13)+..+(1+2+3+..+10+11+12+13+..+20)
// 의 합을 구한는 프로그램
int sum(int start, int end);

int main(void)
{
    int start, end;
    int total = 0;

    scanf_s("%d %d", &start, &end);
    total = sum(start, end);

    printf("total = %d\n", total);

    return(0);
}

int sum(int start, int end)
{
    int i,j;
    int n; // 회전수
    int total = 0;

    n = end - start + 1;
    for (i = 0; i < n; i++)
    {
        for (j = 0; j < n + i; j++)
        {
            total += j;  
        }
    }
    return total;
}
#endif
#if 0
#include <stdio.h>
// 10 과 20 입력할 경우 
// (1+2+3+..+10)+(1+2+3+..+10+11)+(1+2+3+..+10+11+12)+(1+2+3+..+10+11+12)+
// +(1+2+3+..+10+11+12+13)+..+(1+2+3+..+10+11+12+13+..+20)
// 의 합을 구한는 프로그램
int sum(int start, int end);
int main(void)
{
    int start, end;
    int total;

    scanf_s("%d %d", &start, &end);
    total = sum(start, end);
    printf("sum = %d\n", total);

    return(0);
}
int sum(int start, int end)
{
    int i, j;
    int sum = 0;
    for (i = 0; i <= start; i++)
    { // 10, 11, 12,.., 
        for (j = 1; j <= end - start + i; j++)
        {
            sum += j;
        }
    }
    return sum;

}
#endif
#if 0
#include <stdio.h>
// 주석 처리
// (1+2+3+..+10)+(1+2+3+..+10+11)+(1+2+3+..+10+11+12)+(1+2+3+..+10+11+12)+
// +(1+2+3+..+10+11+12+13)+..+(1+2+3+..+10+11+12+13+..+20)
// 의 합을 구한는 프로그램
int main(void)
{
    int i,j;
    int sum = 0;
    int total = 0;

    for (i = 0; i <= 10; i++)
    {
        for (j = 1; j <= 10 + i; j++)
        {
            sum += j;
        }
    }
    printf("sum = %d\n", sum);

    return(0);
}

#endif
#if 0
#include <stdio.h>

int
main(void)
{
    printf("Hello world.\n");
    return(0);
}
#endif


