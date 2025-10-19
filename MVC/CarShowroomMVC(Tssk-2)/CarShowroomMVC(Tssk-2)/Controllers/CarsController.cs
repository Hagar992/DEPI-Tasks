using Microsoft.AspNetCore.Mvc;
using CarShowroomMVC.Models;
using CarShowroomMVC.Repositories;

namespace CarShowroomMVC.Controllers
{
    public class CarsController : Controller
    {
        private readonly ICarRepository _carRepository;
        private readonly IWebHostEnvironment _hostEnvironment;

        public CarsController(ICarRepository carRepository, IWebHostEnvironment hostEnvironment)
        {
            _carRepository = carRepository;
            _hostEnvironment = hostEnvironment;
        }

        public IActionResult Index()
        {
            var cars = _carRepository.GetAll();
            return View(cars);
        }

        public IActionResult Create() => View();

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create(Car car)
        {
            if (ModelState.IsValid)
            {
                // ✅ حفظ الصورة في wwwroot/images
                if (car.ImageFile != null)
                {
                    string wwwRootPath = _hostEnvironment.WebRootPath;
                    string fileName = Path.GetFileNameWithoutExtension(car.ImageFile.FileName);
                    string extension = Path.GetExtension(car.ImageFile.FileName);
                    string filePath = Path.Combine(wwwRootPath, "images", fileName + extension);

                    using (var fileStream = new FileStream(filePath, FileMode.Create))
                    {
                        car.ImageFile.CopyTo(fileStream);
                    }

                    // نحفظ مسار الصورة
                    car.ImageUrl = "/images/" + fileName + extension;
                }

                // ✅ إضافة السيارة لقاعدة البيانات
                _carRepository.Add(car);
                return RedirectToAction(nameof(Index));
            }
            return View(car);
        }

        public IActionResult Edit(int id)
        {
            var car = _carRepository.GetById(id);
            if (car == null) return NotFound();
            return View(car);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Edit(Car car)
        {
            if (ModelState.IsValid)
            {
                var existingCar = _carRepository.GetById(car.Id);
                if (existingCar == null)
                    return NotFound();

                
                existingCar.Name = car.Name;
                existingCar.Brand = car.Brand;
                existingCar.Year = car.Year;
                existingCar.Price = car.Price;

                
                if (!string.IsNullOrEmpty(car.ImageUrl))
                {
                    existingCar.ImageUrl = car.ImageUrl;
                }

               
                if (car.ImageFile != null)
                {
                    string wwwRootPath = _hostEnvironment.WebRootPath;
                    string fileName = Path.GetFileNameWithoutExtension(car.ImageFile.FileName);
                    string extension = Path.GetExtension(car.ImageFile.FileName);
                    string filePath = Path.Combine(wwwRootPath, "images", fileName + extension);

                    using (var fileStream = new FileStream(filePath, FileMode.Create))
                    {
                        car.ImageFile.CopyTo(fileStream);
                    }

                    existingCar.ImageUrl = "/images/" + fileName + extension;
                }

               
                _carRepository.Update(existingCar);
                return RedirectToAction(nameof(Index));
            }
            return View(car);
        }


        public IActionResult Delete(int id)
        {
            _carRepository.Delete(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
