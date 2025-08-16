using System;
using System.Collections.Generic;
using System.Linq;

namespace BankApp_Assignment_3_
{
    // ========= Helpers =========
    public enum TransactionType { Deposit, Withdrawal, TransferIn, TransferOut, Interest }

    public class Transaction
    {
        public DateTime Date { get; init; } = DateTime.Now;
        public TransactionType Type { get; init; }
        public decimal Amount { get; init; }
        public string Note { get; init; } = string.Empty;
        public int? CounterpartyAccount { get; init; }

        public override string ToString()
        {
            string cp = CounterpartyAccount.HasValue ? $" | Counterparty: {CounterpartyAccount}" : "";
            return $"{Date:yyyy-MM-dd HH:mm:ss} | {Type,-11} | Amount: {Amount,10:N2}{cp} | {Note}";
        }
    }

    // ========= Domain: Accounts =========
    public abstract class BankAccount
    {
        private static int _sequence = 100000;

        public int AccountNumber { get; }
        public DateTime DateOpened { get; } = DateTime.Now;
        public decimal Balance { get; protected set; }
        public Customer Owner { get; }

        protected readonly List<Transaction> _transactions = new();

        protected BankAccount(Customer owner, decimal openingBalance = 0)
        {
            Owner = owner ?? throw new ArgumentNullException(nameof(owner));
            AccountNumber = ++_sequence;
            if (openingBalance < 0) throw new ArgumentException("Opening balance cannot be negative.");
            if (openingBalance > 0) Deposit(openingBalance, "Opening balance");
        }

        public IReadOnlyList<Transaction> Transactions => _transactions.AsReadOnly();

        public virtual void Deposit(decimal amount, string note = "")
        {
            if (amount <= 0) throw new ArgumentException("Deposit amount must be > 0.");
            Balance += amount;
            _transactions.Add(new Transaction
            {
                Type = TransactionType.Deposit,
                Amount = amount,
                Note = string.IsNullOrWhiteSpace(note) ? "Deposit" : note
            });
        }

        public virtual bool Withdraw(decimal amount, string note = "")
        {
            if (amount <= 0) throw new ArgumentException("Withdraw amount must be > 0.");
            if (amount > Balance) return false;

            Balance -= amount;
            _transactions.Add(new Transaction
            {
                Type = TransactionType.Withdrawal,
                Amount = amount,
                Note = string.IsNullOrWhiteSpace(note) ? "Withdraw" : note
            });
            return true;
        }

      
        internal void AddTransaction(Transaction tx)
        {
            if (tx == null) throw new ArgumentNullException(nameof(tx));
            _transactions.Add(tx);
        }

        public virtual decimal CalculateMonthlyInterest() => 0m;

        public virtual void ShowAccountDetails()
        {
            Console.WriteLine($"  - Account #{AccountNumber} | Opened: {DateOpened:yyyy-MM-dd} | Balance: {Balance:N2} EGP");
        }
    }

    public class SavingAccount : BankAccount
    {
        public decimal InterestRate { get; } // annual %

        public SavingAccount(Customer owner, decimal openingBalance, decimal interestRate)
            : base(owner, openingBalance)
        {
            if (interestRate < 0) throw new ArgumentException("Interest rate cannot be negative.");
            InterestRate = interestRate;
        }

        public override decimal CalculateMonthlyInterest()
        {
            return Math.Round(Balance * (InterestRate / 100m) / 12m, 2);
        }

        public void ApplyMonthlyInterest()
        {
            var interest = CalculateMonthlyInterest();
            if (interest > 0)
            {
                Balance += interest;
                _transactions.Add(new Transaction
                {
                    Type = TransactionType.Interest,
                    Amount = interest,
                    Note = $"Monthly interest at {InterestRate}% annual"
                });
            }
        }

        public override void ShowAccountDetails()
        {
            base.ShowAccountDetails();
            Console.WriteLine($"    Type: Saving | InterestRate: {InterestRate}% (annual) | Est. Monthly Interest: {CalculateMonthlyInterest():N2} EGP");
        }
    }

    public class CurrentAccount : BankAccount
    {
        public decimal OverdraftLimit { get; }

        public CurrentAccount(Customer owner, decimal openingBalance, decimal overdraftLimit)
            : base(owner, openingBalance)
        {
            if (overdraftLimit < 0) throw new ArgumentException("Overdraft limit cannot be negative.");
            OverdraftLimit = overdraftLimit;
        }

        
        public override bool Withdraw(decimal amount, string note = "")
        {
            if (amount <= 0) throw new ArgumentException("Withdraw amount must be > 0.");
            if (amount > Balance + OverdraftLimit) return false;

            Balance -= amount;
            _transactions.Add(new Transaction
            {
                Type = TransactionType.Withdrawal,
                Amount = amount,
                Note = string.IsNullOrWhiteSpace(note) ? "Withdraw" : note
            });
            return true;
        }

        public override void ShowAccountDetails()
        {
            base.ShowAccountDetails();
            Console.WriteLine($"    Type: Current | Overdraft Limit: {OverdraftLimit:N2} EGP | Available: {(Balance + OverdraftLimit):N2} EGP");
        }
    }

    // ========= Domain: Customer =========
    public class Customer
    {
        private static int _idSeq = 0;

        public int CustomerId { get; }
        public string FullName { get; private set; }
        public string NationalId { get; }   // 14 digits
        public DateTime DateOfBirth { get; private set; }

        private readonly List<BankAccount> _accounts = new();
        public IReadOnlyList<BankAccount> Accounts => _accounts.AsReadOnly();

        public Customer(string fullName, string nationalId, DateTime dob)
        {
            if (string.IsNullOrWhiteSpace(fullName)) throw new ArgumentException("Full name required.");
            if (string.IsNullOrWhiteSpace(nationalId) || nationalId.Length != 14 || !nationalId.All(char.IsDigit))
                throw new ArgumentException("National ID must be exactly 14 digits.");
            if (dob > DateTime.Today) throw new ArgumentException("Date of birth invalid.");

            CustomerId = ++_idSeq;
            FullName = fullName.Trim();
            NationalId = nationalId;
            DateOfBirth = dob;
        }

        public void Update(string? newName = null, DateTime? newDob = null)
        {
            if (!string.IsNullOrWhiteSpace(newName)) FullName = newName.Trim();
            if (newDob.HasValue) DateOfBirth = newDob.Value;
        }

        public decimal TotalBalance() => _accounts.Sum(a => a.Balance);

        internal void AddAccount(BankAccount account) => _accounts.Add(account);

        internal bool CanBeRemoved() => _accounts.All(a => a.Balance == 0m);
    }

    // ========= Domain: Bank =========
    public class Bank
    {
        public string Name { get; }
        public string BranchCode { get; }

        private readonly List<Customer> _customers = new();
        public IReadOnlyList<Customer> Customers => _customers.AsReadOnly();

        public Bank(string name, string branchCode)
        {
            if (string.IsNullOrWhiteSpace(name)) throw new ArgumentException("Bank name required.");
            if (string.IsNullOrWhiteSpace(branchCode)) throw new ArgumentException("Branch code required.");
            Name = name.Trim();
            BranchCode = branchCode.Trim();
        }

        // ----- Customer Management -----
        public Customer AddCustomer(string fullName, string nationalId, DateTime dob)
        {
            if (_customers.Any(c => c.NationalId == nationalId))
                throw new InvalidOperationException("A customer with the same National ID already exists.");

            var cst = new Customer(fullName, nationalId, dob);
            _customers.Add(cst);
            return cst;
        }

        public IEnumerable<Customer> SearchCustomers(string? nameOrNationalId)
        {
            if (string.IsNullOrWhiteSpace(nameOrNationalId)) return Enumerable.Empty<Customer>();
            string key = nameOrNationalId.Trim().ToLower();

            return _customers.Where(c =>
                c.FullName.ToLower().Contains(key) ||
                c.NationalId.Contains(key));
        }

        public void UpdateCustomer(int customerId, string? newName = null, DateTime? newDob = null)
        {
            var c = _customers.FirstOrDefault(x => x.CustomerId == customerId)
                ?? throw new KeyNotFoundException("Customer not found.");
            c.Update(newName, newDob);
        }

        public bool RemoveCustomer(int customerId)
        {
            var c = _customers.FirstOrDefault(x => x.CustomerId == customerId);
            if (c == null) return false;
            if (!c.CanBeRemoved()) return false;

            return _customers.Remove(c);
        }

        // ----- Accounts -----
        public SavingAccount OpenSavingAccount(Customer owner, decimal openingBalance, decimal interestRate)
        {
            var acc = new SavingAccount(owner, openingBalance, interestRate);
            owner.AddAccount(acc);
            return acc;
        }

        public CurrentAccount OpenCurrentAccount(Customer owner, decimal openingBalance, decimal overdraftLimit)
        {
            var acc = new CurrentAccount(owner, openingBalance, overdraftLimit);
            owner.AddAccount(acc);
            return acc;
        }

        public BankAccount? FindAccount(int accountNumber)
        {
            foreach (var c in _customers)
                foreach (var a in c.Accounts)
                    if (a.AccountNumber == accountNumber) return a;
            return null;
        }

        // ----- Operations -----
        public bool Transfer(int fromAccountNumber, int toAccountNumber, decimal amount, string note = "Transfer")
        {
            if (amount <= 0) throw new ArgumentException("Transfer amount must be > 0.");

            var from = FindAccount(fromAccountNumber) ?? throw new KeyNotFoundException("From account not found.");
            var to = FindAccount(toAccountNumber) ?? throw new KeyNotFoundException("To account not found.");
            if (from == to) throw new ArgumentException("Cannot transfer to the same account.");

            bool ok = from.Withdraw(amount, $"{note} to {toAccountNumber}");
            if (!ok) return false;

            to.Deposit(amount, $"{note} from {fromAccountNumber}");

            from.AddTransaction(new Transaction
            {
                Type = TransactionType.TransferOut,
                Amount = amount,
                Note = note,
                CounterpartyAccount = toAccountNumber
            });

            to.AddTransaction(new Transaction
            {
                Type = TransactionType.TransferIn,
                Amount = amount,
                Note = note,
                CounterpartyAccount = fromAccountNumber
            });

            return true;
        }

        // ----- Reporting -----
        public void PrintCustomerSummary(Customer c)
        {
            Console.WriteLine($"> Customer #{c.CustomerId} | {c.FullName} | NID: {c.NationalId} | DOB: {c.DateOfBirth:yyyy-MM-dd}");
            foreach (var a in c.Accounts)
            {
                a.ShowAccountDetails();
            }
            Console.WriteLine($"  >> Total Balance: {c.TotalBalance():N2} EGP");
            Console.WriteLine(new string('-', 60));
        }

        public void PrintBankReport()
        {
            Console.WriteLine($"\n===== {Name} [Branch: {BranchCode}] - Bank Report =====");
            if (_customers.Count == 0)
            {
                Console.WriteLine("No customers.");
                return;
            }

            foreach (var c in _customers)
                PrintCustomerSummary(c);

            Console.WriteLine("=======================================================\n");
        }

        public void PrintAccountHistory(int accountNumber)
        {
            var acc = FindAccount(accountNumber) ?? throw new KeyNotFoundException("Account not found.");
            Console.WriteLine($"\n--- Transactions for Account #{acc.AccountNumber} (Owner: {acc.Owner.FullName}) ---");
            if (!acc.Transactions.Any())
            {
                Console.WriteLine("No transactions yet.");
            }
            else
            {
                foreach (var t in acc.Transactions)
                    Console.WriteLine(t);
            }
            Console.WriteLine("--------------------------------------------------------\n");
        }

        public void ApplyMonthlyInterestToAllSavings()
        {
            foreach (var c in _customers)
                foreach (var a in c.Accounts.OfType<SavingAccount>())
                    a.ApplyMonthlyInterest();
        }
    }

    // ========= Demo / Main =========
    class Program
    {
        static void Main()
        {
            var bank = new Bank("DEPI Bank", "BR-CAIRO-001");

            var c1 = bank.AddCustomer("Shams Ali", "29801011234567", new DateTime(1998, 1, 1));
            var c2 = bank.AddCustomer("Omar Hassan", "30005251234567", new DateTime(2000, 5, 25));

            var sa1 = bank.OpenSavingAccount(c1, openingBalance: 5000m, interestRate: 6m);
            var ca1 = bank.OpenCurrentAccount(c1, openingBalance: 1500m, overdraftLimit: 1000m);

            var ca2 = bank.OpenCurrentAccount(c2, openingBalance: 3000m, overdraftLimit: 500m);

            sa1.Deposit(1000m, "Salary savings");
            ca1.Withdraw(400m, "Grocery");
            bank.Transfer(ca2.AccountNumber, ca1.AccountNumber, 600m, "Rent share");

            bank.PrintBankReport();

            bank.ApplyMonthlyInterestToAllSavings();

            bank.PrintBankReport();

            Console.WriteLine("Search results for 'Shams':");
            foreach (var cx in bank.SearchCustomers("Shams"))
                bank.PrintCustomerSummary(cx);

            bank.UpdateCustomer(c2.CustomerId, newName: "Omar H. Youssef");

            bank.PrintAccountHistory(sa1.AccountNumber);
            bank.PrintAccountHistory(ca1.AccountNumber);
            bank.PrintAccountHistory(ca2.AccountNumber);

            Console.WriteLine($"Try remove {c1.FullName}: " + (bank.RemoveCustomer(c1.CustomerId) ? "Removed" : "Cannot remove (non-zero balances)"));

            foreach (var a in c2.Accounts.ToList())
            {
                if (a.Balance > 0) a.Withdraw(a.Balance, "Close out");
            }
            Console.WriteLine($"Try remove {c2.FullName}: " + (bank.RemoveCustomer(c2.CustomerId) ? "Removed" : "Cannot remove"));

            bank.PrintBankReport();

            Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
        }
    }
}
