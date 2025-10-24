using CarShowroomMVC.Interfaces;
using CarShowroomMVC.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarShowroomMVC.Services
{
    public class CarService : ICarService
    {
        private readonly IGenericRepository<Car> _repository;

        public CarService(IGenericRepository<Car> repository)
        {
            _repository = repository;
        }

        public async Task<IEnumerable<Car>> GetAllAsync() => await _repository.GetAllAsync();
        public async Task<Car?> GetByIdAsync(int id) => await _repository.GetByIdAsync(id);
        public async Task AddAsync(Car car)
        {
            await _repository.AddAsync(car);
            await _repository.SaveAsync();
        }
        public async Task UpdateAsync(Car car)
        {
            await _repository.UpdateAsync(car);
            await _repository.SaveAsync();
        }
        public async Task DeleteAsync(int id)
        {
            await _repository.DeleteAsync(id);
            await _repository.SaveAsync();
        }
    }
}
