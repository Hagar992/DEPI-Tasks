using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace LINQtoObject
{
    #region class used to store grouping result
    public class GroupingResultClass
    {
        public string SubjectName { get; set; }
        public List<string> BooksNames { get; set; }
    }
    #endregion

    class Program
    {
        static void Main(string[] args)
        {
            // 1️⃣ Display book title and its ISBN
            var q1 = from b in SampleData.Books
                     select new { b.Title, b.Isbn };

            Console.WriteLine("---- Q1 ----");
            foreach (var item in q1)
                Console.WriteLine($"{item.Title} - {item.Isbn}");

            // 2️⃣ First 3 books with price more than 25
            var q2 = SampleData.Books
                               .Where(b => b.Price > 25)
                               .Take(3);

            Console.WriteLine("\n---- Q2 ----");
            foreach (var book in q2)
                Console.WriteLine($"{book.Title} - {book.Price}");

            // 3️⃣ Book title along with its publisher (2 methods)
            var q3_1 = from b in SampleData.Books
                       select new { b.Title, Publisher = b.Publisher.Name };

            Console.WriteLine("\n---- Q3 (Query Syntax) ----");
            foreach (var item in q3_1)
                Console.WriteLine($"{item.Title} - {item.Publisher}");

            var q3_2 = SampleData.Books
                                 .Select(b => new { b.Title, Publisher = b.Publisher.Name });

            Console.WriteLine("\n---- Q3 (Method Syntax) ----");
            foreach (var item in q3_2)
                Console.WriteLine($"{item.Title} - {item.Publisher}");

            // 4️⃣ Number of books cost > 20
            var q4 = SampleData.Books.Count(b => b.Price > 20);
            Console.WriteLine($"\n---- Q4 ----\nCount = {q4}");

            // 5️⃣ Book title, price, subject sorted by subject asc, price desc
            var q5 = SampleData.Books
                               .OrderBy(b => b.Subject.Name)
                               .ThenByDescending(b => b.Price)
                               .Select(b => new { b.Title, b.Price, Subject = b.Subject.Name });

            Console.WriteLine("\n---- Q5 ----");
            foreach (var item in q5)
                Console.WriteLine($"{item.Title} - {item.Price} - {item.Subject}");

            // 6️⃣ All subjects with books (2 methods)
            var q6_1 = from s in SampleData.Subjects
                       join b in SampleData.Books
                       on s equals b.Subject into sb
                       select new { Subject = s.Name, Books = sb };

            Console.WriteLine("\n---- Q6 (Join) ----");
            foreach (var item in q6_1)
            {
                Console.WriteLine(item.Subject);
                foreach (var b in item.Books)
                    Console.WriteLine("   " + b.Title);
            }

            var q6_2 = SampleData.Subjects
                                 .Select(s => new { Subject = s.Name, Books = SampleData.Books.Where(b => b.Subject == s) });

            Console.WriteLine("\n---- Q6 (Navigation) ----");
            foreach (var item in q6_2)
            {
                Console.WriteLine(item.Subject);
                foreach (var b in item.Books)
                    Console.WriteLine("   " + b.Title);
            }

            // 7️⃣ Book title & price from GetBooks()
            var q7 = SampleData.GetBooks().Cast<Book>()
                               .Select(b => new { b.Title, b.Price });

            Console.WriteLine("\n---- Q7 ----");
            foreach (var item in q7)
                Console.WriteLine($"{item.Title} - {item.Price}");

            // 8️⃣ Books grouped by publisher & subject
            var q8 = from b in SampleData.Books
                     group b by new { Publisher = b.Publisher.Name, Subject = b.Subject.Name } into g
                     select g;

            Console.WriteLine("\n---- Q8 ----");
            foreach (var group in q8)
            {
                Console.WriteLine($"{group.Key.Publisher} - {group.Key.Subject}");
                foreach (var b in group)
                    Console.WriteLine("   " + b.Title);
            }

            // 🎁 Bonus – FindBooksSorted
            Console.Write("\nEnter publisher: ");
            string pub = Console.ReadLine();

            Console.Write("Sort by (Title/Price/Date): ");
            string sortBy = Console.ReadLine();

            Console.Write("Order (ASC/DESC): ");
            string order = Console.ReadLine();

            FindBooksSorted(pub, sortBy, order);
        }

        static void FindBooksSorted(string publisherName, string sortBy, string sortOrder)
        {
            var books = SampleData.Books
                                  .Where(b => b.Publisher.Name.Equals(publisherName, StringComparison.OrdinalIgnoreCase));

            IOrderedEnumerable<Book> sortedBooks;

            switch (sortBy.ToLower())
            {
                case "title":
                    sortedBooks = (sortOrder.ToLower() == "asc")
                                  ? books.OrderBy(b => b.Title)
                                  : books.OrderByDescending(b => b.Title);
                    break;

                case "price":
                    sortedBooks = (sortOrder.ToLower() == "asc")
                                  ? books.OrderBy(b => b.Price)
                                  : books.OrderByDescending(b => b.Price);
                    break;

                case "date":
                    sortedBooks = (sortOrder.ToLower() == "asc")
                                  ? books.OrderBy(b => b.PublicationDate)
                                  : books.OrderByDescending(b => b.PublicationDate);
                    break;

                default:
                    Console.WriteLine("Invalid sort criteria");
                    return;
            }

            Console.WriteLine("\n---- Bonus Result ----");
            foreach (var b in sortedBooks)
                Console.WriteLine($"{b.Title} - {b.Price} - {b.PublicationDate.ToShortDateString()}");
        }
    }
}
