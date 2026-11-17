// 02_class.cpp: 클래스, 생성자와 소멸자, 연산자 오버로딩, 템플릿, unique_ptr

#include <iostream>
#include <memory>
#include <string>

struct v2
{
    float X;
    float Y;
};

inline v2
operator+(v2 A, v2 B)
{
    v2 Result = {A.X + B.X, A.Y + B.Y};
    return(Result);
}

inline v2
operator*(float Scale, v2 A)
{
    v2 Result = {Scale*A.X, Scale*A.Y};
    return(Result);
}

std::ostream &
operator<<(std::ostream &Out, v2 A)
{
    return(Out << '(' << A.X << ", " << A.Y << ')');
}

// 생성자와 소멸자가 불리는 때를 화면에 표시한다.
class account
{
public:
    account(const std::string &OwnerName, int StartBalance)
        : Owner(OwnerName), Balance(StartBalance)
    {
        std::cout << "  [생성] " << Owner << '\n';
    }

    ~account()
    {
        std::cout << "  [소멸] " << Owner << '\n';
    }

    void Deposit(int Amount)
    {
        Balance += Amount;
    }

    bool Withdraw(int Amount)
    {
        if(Amount > Balance)
        {
            return(false);
        }
        Balance -= Amount;
        return(true);
    }

    int GetBalance() const
    {
        return(Balance);
    }

    const std::string &GetOwner() const
    {
        return(Owner);
    }

private:
    std::string Owner;
    int Balance;
};

template <typename T> T
Largest(T A, T B)
{
    return((A > B) ? A : B);
}

int
main()
{
    v2 Position = {1.0f, 2.0f};
    v2 Velocity = {0.5f, -1.0f};
    std::cout << "Position + 2*Velocity = " << (Position + 2.0f*Velocity) << "\n\n";

    std::cout << "블록 시작\n";
    {
        account First("홍길동", 1000);
        First.Deposit(500);
        bool Ok = First.Withdraw(2000);
        std::cout << "  2000원 출금 " << (Ok ? "성공" : "실패")
                  << ", 잔액 " << First.GetBalance() << "원\n";

        std::unique_ptr<account> Second = std::make_unique<account>("성춘향", 300);
        std::cout << "  " << Second->GetOwner() << " 잔액 " << Second->GetBalance() << "원\n";
    }
    std::cout << "블록 끝 (만든 순서의 반대로 소멸)\n\n";

    std::cout << "Largest(3, 7) = " << Largest(3, 7) << '\n';
    std::cout << "Largest(2.5, 1.5) = " << Largest(2.5, 1.5) << '\n';
    std::cout << "Largest(apple, banana) = "
              << Largest(std::string("apple"), std::string("banana")) << '\n';

    return(0);
}
