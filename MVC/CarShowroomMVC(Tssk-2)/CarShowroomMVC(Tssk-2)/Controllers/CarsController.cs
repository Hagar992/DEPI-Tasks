using Microsoft.AspNetCore.Mvc;
using CarShowroomMVC.Models;

namespace CarShowroomMVC.Controllers
{
    public class CarsController : Controller
    {
        private readonly IWebHostEnvironment _environment;
        private static List<Car> _cars = new(); // مؤقتًا بدل قاعدة بيانات

        public CarsController(IWebHostEnvironment environment)
        {
            _environment = environment;
        }

        // GET: /Cars
        public IActionResult Index()
        {
            return View(_cars);
        }

        // GET: /Cars/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: /Cars/Create
        [HttpPost]
        public IActionResult Create(Car car)
        {
            if (car.ImageFile != null)
            {
                string wwwRootPath = _environment.WebRootPath;
                string fileName = Path.GetFileNameWithoutExtension(car.ImageFile.FileName);
                string extension = Path.GetExtension(car.ImageFile.FileName);
                string fullName = fileName + DateTime.Now.ToString("yymmssfff") + extension;
                string path = Path.Combine(wwwRootPath + "/images/", fullName);

                using (var fileStream = new FileStream(path, FileMode.Create))
                {
                    car.ImageFile.CopyTo(fileStream);
                }

                car.ImageUrl = "/images/" + fullName;
            }

            _cars.Add(car);
            return RedirectToAction(nameof(Index));
        }

        // GET: /Cars/Edit/5
        public IActionResult Edit(int id)
        {
            var car = _cars.FirstOrDefault(x => x.Id == id);
            if (car == null) return NotFound();
            return View(car);
        }

        // POST: /Cars/Edit
        [HttpPost]
        public IActionResult Edit(Car car)
        {
            var existingCar = _cars.FirstOrDefault(x => x.Id == car.Id);
            if (existingCar == null) return NotFound();

            if (car.ImageFile != null)
            {
                string wwwRootPath = _environment.WebRootPath;
                string fileName = Path.GetFileNameWithoutExtension(car.ImageFile.FileName);
                string extension = Path.GetExtension(car.ImageFile.FileName);
                string fullName = fileName + DateTime.Now.ToString("yymmssfff") + extension;
                string path = Path.Combine(wwwRootPath + "/images/", fullName);

                using (var fileStream = new FileStream(path, FileMode.Create))
                {
                    car.ImageFile.CopyTo(fileStream);
                }

                existingCar.ImageUrl = "/images/" + fullName;
            }

            existingCar.Name = car.Name;
            existingCar.Brand = car.Brand;
            existingCar.Price = car.Price;
            existingCar.Year = car.Year;

            return RedirectToAction(nameof(Index));
        }

        // GET: /Cars/Delete/5
        public IActionResult Delete(int id)
        {
            var car = _cars.FirstOrDefault(x => x.Id == id);
            if (car == null) return NotFound();
            return View(car);
        }

        [HttpPost, ActionName("DeleteConfirmed")]
        public IActionResult DeleteConfirmed(int id)
        {
            var car = _cars.FirstOrDefault(x => x.Id == id);
            if (car != null)
                _cars.Remove(car);

            return RedirectToAction(nameof(Index));
        }

        // GET: /Cars/Details/5
        public IActionResult Details(int id)
        {
            var car = _cars.FirstOrDefault(x => x.Id == id);
            if (car == null) return NotFound();
            return View(car);
        }
    }
}
