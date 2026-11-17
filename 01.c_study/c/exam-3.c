

#if 1
// Storage Class
#include <stdio.h>
void func(int a);
int a, b;
int main(void)
{
    printf("a = %d, b = %d\n", a, b); // a= 0, b = 0;
    a = 5;

    func(5);
    printf("a = %d, b = %d\n", a, b); // a= 5, b = 2;

    return(0);
}
void func(int a)
{
    b = 2;
    a += 2;
}
#endif 


#if 0
// Storage Class
#include <stdio.h>

int main(void)
{
    int i;
    i = 5;
    {
        int i;
        i = 3;
        printf("i = %d\n", i);
    }
    printf("i = %d\n", i);
    return(0);
}
#endif 
#if 0
// Storage Class
#include <stdio.h>

int main(void)
{
    int a = 10, b = 20;
    printf("바꾸기 전 a: %d, b: %d\n", a, b);
    {
        int a = 10, b = 20;
        int tmp;
        tmp = a;
        a = b;
        b = tmp;
    }
    printf("바꾼 후  a: %d, b: %d\n", a, b);

    return(0);
}
#endif 

