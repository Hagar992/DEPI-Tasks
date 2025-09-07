using System;

namespace calc_extension_method
{
    
    public static class IntExtensions
    {
       
        public static int Calc(this int x, int y, Func<int, int, int> operation)
        {
            return operation(x, y);
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            int sum = 5.Calc(3, (a, b) => a + b);  
            int mul = 5.Calc(3, (a, b) => a * b);  
            int sub = 5.Calc(3, (a, b) => a - b);  
            int div = 5.Calc(3, (a, b) => a / b);  

            Console.WriteLine($"Sum: {sum}, Mul: {mul}, Sub: {sub}, Div: {div}");
           
        }
    }
}
