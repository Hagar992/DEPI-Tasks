public class Catalog
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Desc { get; set; }

    // علاقة 1 - Many مع News
    public ICollection<News> NewsList { get; set; }
}

public class Author
{
    public int Id { get; set; }
    public string Name { get; set; }
    public int Age { get; set; }

    public string Username { get; set; }
    public string Password { get; set; }
    public DateTime JoinDate { get; set; }

    // علاقة 1 - Many مع News
    public ICollection<News> NewsList { get; set; }
}

public class News
{
    public int Id { get; set; }
    public string Title { get; set; }
    public string Bref { get; set; }
    public string Desc { get; set; }
    public string Time { get; set; }
    public DateTime Date { get; set; }

    // العلاقات
    public int AuthorId { get; set; }
    public Author Author { get; set; }

    public int Cat_Id { get; set; }
    public Catalog Catalog { get; set; }
}
