/* 02_input.c: scanf로 이름과 정수를 입력 받는다. 0을 입력하면 끝난다. */

#include <stdio.h>

int
main(void)
{
    char Name[64];
    printf("이름을 입력하세요: ");
    if(scanf("%63s", Name) != 1)
    {
        return(1);
    }

    printf("%s님, 정수를 하나씩 입력하세요. 0을 입력하면 끝납니다.\n", Name);

    int Count = 0;
    int Sum = 0;
    int Max = 0;
    for(;;)
    {
        int Value;
        printf("> ");
        if(scanf("%d", &Value) != 1)
        {
            printf("정수가 아니어서 끝냅니다.\n");
            break;
        }
        if(Value == 0)
        {
            break;
        }

        if((Count == 0) || (Value > Max))
        {
            Max = Value;
        }
        Sum += Value;
        ++Count;
    }

    if(Count > 0)
    {
        printf("개수 %d, 합계 %d, 평균 %.2f, 최댓값 %d\n", Count, Sum, (double)Sum / Count, Max);
    }
    else
    {
        printf("입력한 수가 없습니다.\n");
    }

    return(0);
}
