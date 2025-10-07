using System.Diagnostics;
using CarSales.Models;
using Microsoft.AspNetCore.Mvc;


namespace CarSales.Controllers
{
    public class AdminController: Controller
    {
        

        public IActionResult Index()
        {
            return View();
        }
    }
}
