// 01_hello.cpp: iostream, string, vector, 범위 for, 람다, sort, format

#include <algorithm>
#include <format>
#include <iostream>
#include <string>
#include <vector>

int
main()
{
    std::cout << "Hello, C++!\n";
    std::cout << "안녕하세요. C++ 공부를 시작합니다.\n\n";

    std::vector<std::string> Fruits = {"banana", "apple", "cherry", "grape"};
    std::sort(Fruits.begin(), Fruits.end());
    std::cout << "정렬한 과일:";
    for(const std::string &Fruit : Fruits)
    {
        std::cout << ' ' << Fruit;
    }
    std::cout << '\n';

    std::vector<int> Numbers = {5, 3, 8, 1, 9, 2};
    auto IsEven = [](int Value) { return((Value % 2) == 0); };
    auto EvenCount = std::count_if(Numbers.begin(), Numbers.end(), IsEven);
    int Sum = 0;
    for(int Value : Numbers)
    {
        Sum += Value;
    }
    std::cout << std::format("숫자 {}개, 합계 {}, 짝수 {}개\n", Numbers.size(), Sum, EvenCount);
    std::cout << std::format("__cplusplus = {}\n", __cplusplus);

    return(0);
}
