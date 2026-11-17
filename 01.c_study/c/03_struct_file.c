/* 03_struct_file.c: 구조체 배열, 포인터, qsort, malloc, 파일 쓰기와 읽기
   scores.txt는 실행한 폴더에 만들어진다. gvim의 F5는 이 소스가 있는 c 폴더에서
   실행한다. */

#include <stdio.h>
#include <stdlib.h>

typedef struct student
{
    char Name[32];
    int Score;
} student;

/* qsort가 부르는 비교 함수. 점수가 높은 학생이 앞에 온다. */
static int
CompareByScore(const void *A, const void *B)
{
    const student *StudentA = (const student *)A;
    const student *StudentB = (const student *)B;
    return(StudentB->Score - StudentA->Score);
}

static void
PrintStudents(const student *Students, int Count)
{
    for(int Index = 0; Index < Count; ++Index)
    {
        const student *Student = Students + Index;
        printf("%d. %-8s %3d\n", Index + 1, Student->Name, Student->Score);
    }
}

int
main(void)
{
    student Students[] =
    {
        {"김민수", 82},
        {"이서연", 95},
        {"박지훈", 77},
        {"최유진", 88},
    };
    int Count = (int)(sizeof(Students) / sizeof(Students[0]));

    qsort(Students, Count, sizeof(student), CompareByScore);
    printf("점수 순서\n");
    PrintStudents(Students, Count);

    FILE *File = fopen("scores.txt", "w");
    if(!File)
    {
        perror("scores.txt");
        return(1);
    }
    for(int Index = 0; Index < Count; ++Index)
    {
        fprintf(File, "%s %d\n", Students[Index].Name, Students[Index].Score);
    }
    fclose(File);

    /* 파일에서 다시 읽는다. 읽을 자리는 malloc으로 잡는다. */
    File = fopen("scores.txt", "r");
    if(!File)
    {
        perror("scores.txt");
        return(1);
    }
    student *Loaded = (student *)malloc(Count*sizeof(student));
    if(!Loaded)
    {
        fclose(File);
        return(1);
    }
    int LoadedCount = 0;
    while((LoadedCount < Count) &&
          (fscanf(File, "%31s %d", Loaded[LoadedCount].Name, &Loaded[LoadedCount].Score) == 2))
    {
        ++LoadedCount;
    }
    fclose(File);

    int Total = 0;
    for(int Index = 0; Index < LoadedCount; ++Index)
    {
        Total += Loaded[Index].Score;
    }
    printf("\nscores.txt에서 %d명을 읽었다. 평균 %.1f\n", LoadedCount,
           (LoadedCount > 0) ? (double)Total / LoadedCount : 0.0);
    PrintStudents(Loaded, LoadedCount);

    free(Loaded);
    return(0);
}
