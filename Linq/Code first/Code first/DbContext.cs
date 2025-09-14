using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Migrations;
using System.Collections.Generic;

public class MyDbContext : DbContext
{
    public DbSet<Catalog> Catalogs { get; set; }
    public DbSet<Author> Authors { get; set; }
    public DbSet<News> News { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
      
        optionsBuilder.UseSqlServer(@"Server=.;Database=NewsDB;Trusted_Connection=True;");

        //Add - Migration InitialCreate
        //Update - Database

    }
}
