using System;

class Program
{
    static void Main()
    {
      
        Console.WriteLine("Hello!");
 
        Console.Write("Input the first number: ");
        double firstNumber = Convert.ToDouble(Console.ReadLine());
     
        Console.Write("Input the second number: ");
        double secondNumber = Convert.ToDouble(Console.ReadLine());

        Console.WriteLine("What do you want to do with those numbers?");
        Console.WriteLine("[A]dd");
        Console.WriteLine("[S]ubtract");
        Console.WriteLine("[M]ultiply");
       
        string? choice = Console.ReadLine();
       
        switch (choice?.ToLower()) 
        {
            case "a":
                Console.WriteLine($"{firstNumber} + {secondNumber} = {firstNumber + secondNumber}");
                break;

            case "s":
                Console.WriteLine($"{firstNumber} - {secondNumber} = {firstNumber - secondNumber}");
                break;

            case "m":
                Console.WriteLine($"{firstNumber} * {secondNumber} = {firstNumber * secondNumber}");
                break;

            default:
                Console.WriteLine("Invalid option");
                break;
        }

        Console.WriteLine("Press any key to close");
        Console.ReadKey();
    }
}
