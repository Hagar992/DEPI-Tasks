using System;
using System.Collections.Generic;

class BankAccount
{
    public int AccountNumber { get; set; }
    public decimal Balance { get; set; }

    public BankAccount(int accountNumber, decimal balance)
    {
        AccountNumber = accountNumber;
        Balance = balance;
    }

    public void Deposit(decimal amount)
    {
        Balance += amount;
        Console.WriteLine($"Deposited: {amount}, New Balance: {Balance}");
    }

    public virtual void Withdraw(decimal amount)
    {
        if (amount <= Balance)
        {
            Balance -= amount;
            Console.WriteLine($"Withdrawn: {amount}, New Balance: {Balance}");
        }
        else
        {
            Console.WriteLine("Insufficient funds!");
        }
    }

    public virtual void ShowAccountDetails()
    {
        Console.WriteLine($"Account Number: {AccountNumber}, Balance: {Balance}");
    }
}

class SavingAccount : BankAccount
{
    public decimal InterestRate { get; set; }

    public SavingAccount(int accountNumber, decimal balance, decimal interestRate)
        : base(accountNumber, balance)
    {
        InterestRate = interestRate;
    }

    public override void ShowAccountDetails()
    {
        base.ShowAccountDetails();
        Console.WriteLine($"Interest Rate: {InterestRate}%");
    }

    public void CalculateInterest()
    {
        decimal interest = Balance * (InterestRate / 100);
        Console.WriteLine($"Interest earned: {interest}");
    }
}

class CurrentAccount : BankAccount
{
    public decimal OverdraftLimit { get; set; }

    public CurrentAccount(int accountNumber, decimal balance, decimal overdraftLimit)
        : base(accountNumber, balance)
    {
        OverdraftLimit = overdraftLimit;
    }

    public override void Withdraw(decimal amount)
    {
        if (amount <= Balance + OverdraftLimit)
        {
            Balance -= amount;
            Console.WriteLine($"Withdrawn: {amount}, New Balance: {Balance}");
        }
        else
        {
            Console.WriteLine("Overdraft limit exceeded!");
        }
    }

    public override void ShowAccountDetails()
    {
        base.ShowAccountDetails();
        Console.WriteLine($"Overdraft Limit: {OverdraftLimit}");
    }
}

class Program
{
    static void Main()
    {
        //  SavingAccount
        SavingAccount saving = new SavingAccount(1001, 5000m, 5m);

        //  CurrentAccount
        CurrentAccount current = new CurrentAccount(2001, 3000m, 1000m);

        // List<BankAccount>
        List<BankAccount> accounts = new List<BankAccount>();
        accounts.Add(saving);
        accounts.Add(current);

        // Loop
        foreach (var acc in accounts)
        {
            acc.ShowAccountDetails();
            Console.WriteLine();

            if (acc is SavingAccount sAcc)
            {
                sAcc.CalculateInterest();
            }

            Console.WriteLine("----------------------------");
        }
    }
}
