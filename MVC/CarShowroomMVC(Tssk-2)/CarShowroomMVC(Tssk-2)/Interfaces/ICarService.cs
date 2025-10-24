using CarShowroomMVC.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CarShowroomMVC.Interfaces
{
    public interface ICarService
    {
        Task<IEnumerable<Car>> GetAllAsync();
        Task<Car?> GetByIdAsync(int id);
        Task AddAsync(Car car);
        Task UpdateAsync(Car car);
        Task DeleteAsync(int id);
    }
}
