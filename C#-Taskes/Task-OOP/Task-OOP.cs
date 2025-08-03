using System;
using System.Collections.Generic;

// Base User Class
public abstract class User
{
    public int UserID { get; set; }
    public string Username { get; set; }
    public string Password { get; set; }
    public string UserType { get; set; }
    public string Email { get; set; }
    public string FullName { get; set; }

    public User(int userID, string username, string password, string userType, string email, string fullName)
    {
        UserID = userID;
        Username = username;
        Password = password;
        UserType = userType;
        Email = email;
        FullName = fullName;
    }
}

// Training Manager (Derived from User)
public class TrainingManager : User
{
    public List<Branch> Branches { get; set; }
    public List<Track> Tracks { get; set; }
    public List<Intake> Intakes { get; set; }
    public List<Student> Students { get; set; }

    public TrainingManager(int userID, string username, string password, string email, string fullName)
        : base(userID, username, password, "TrainingManager", email, fullName)
    {
        Branches = new List<Branch>();
        Tracks = new List<Track>();
        Intakes = new List<Intake>();
        Students = new List<Student>();
    }

    public void AddBranch(Branch branch) => Branches.Add(branch);
    public void AddTrack(Track track) => Tracks.Add(track);
    public void AddIntake(Intake intake) => Intakes.Add(intake);
    public void AddStudent(Student student) => Students.Add(student);
}

// Instructor (Derived from User)
public class Instructor : User
{
    public List<Course> Courses { get; set; }
    public List<Exam> Exams { get; set; }

    public Instructor(int userID, string username, string password, string email, string fullName)
        : base(userID, username, password, "Instructor", email, fullName)
    {
        Courses = new List<Course>();
        Exams = new List<Exam>();
    }

    public void CreateExam(Course course, List<Question> questions, DateTime startTime, DateTime endTime)
    {
        // Logic to create exam
        var exam = new Exam(this, course, questions, startTime, endTime);
        Exams.Add(exam);
    }
}

// Student (Derived from User)
public class Student : User
{
    public int StudentID { get; set; }
    public Intake Intake { get; set; }
    public Branch Branch { get; set; }
    public Track Track { get; set; }
    public List<Exam> EnrolledExams { get; set; }
    public List<StudentAnswer> Answers { get; set; }

    public Student(int userID, string username, string password, string email, string fullName, int studentID)
        : base(userID, username, password, "Student", email, fullName)
    {
        StudentID = studentID;
        EnrolledExams = new List<Exam>();
        Answers = new List<StudentAnswer>();
    }

    public void SubmitAnswer(Question question, string answer)
    {
        var studentAnswer = new StudentAnswer(this, question, answer);
        Answers.Add(studentAnswer);
    }
}

// Supporting Entities
public class Track
{
    public int TrackID { get; set; }
    public string TrackName { get; set; }
    public string Description { get; set; }

    public Track(int trackID, string trackName, string description)
    {
        TrackID = trackID;
        TrackName = trackName;
        Description = description;
    }
}

public class Branch
{
    public int BranchID { get; set; }
    public string BranchName { get; set; }
    public string Description { get; set; }
    public List<Track> Tracks { get; set; }

    public Branch(int branchID, string branchName, string description)
    {
        BranchID = branchID;
        BranchName = branchName;
        Description = description;
        Tracks = new List<Track>();
    }
}

public class Intake
{
    public int IntakeID { get; set; }
    public int IntakeYear { get; set; }
    public string Description { get; set; }
    public List<Student> Students { get; set; }

    public Intake(int intakeID, int intakeYear, string description)
    {
        IntakeID = intakeID;
        IntakeYear = intakeYear;
        Description = description;
        Students = new List<Student>();
    }
}

public class Course
{
    public int CourseID { get; set; }
    public string CourseName { get; set; }
    public string Description { get; set; }
    public int MaxDegree { get; set; }
    public int MinDegree { get; set; }
    public Instructor Instructor { get; set; }
    public List<Exam> Exams { get; set; }

    public Course(int courseID, string courseName, string description, int maxDegree, int minDegree)
    {
        CourseID = courseID;
        CourseName = courseName;
        Description = description;
        MaxDegree = maxDegree;
        MinDegree = minDegree;
        Exams = new List<Exam>();
    }
}

public class Question
{
    public int QuestionID { get; set; }
    public string QuestionText { get; set; }
    public string QuestionType { get; set; } // MultipleChoice, TrueFalse, Text
    public string CorrectAnswer { get; set; }
    public string BestAnswer { get; set; } // For text questions
    public int Degree { get; set; }
    public Course Course { get; set; }

    public Question(int questionID, string questionText, string questionType, string correctAnswer, string bestAnswer, int degree)
    {
        QuestionID = questionID;
        QuestionText = questionText;
        QuestionType = questionType;
        CorrectAnswer = correctAnswer;
        BestAnswer = bestAnswer;
        Degree = degree;
    }
}

public class Exam
{
    public int ExamID { get; set; }
    public string ExamType { get; set; } // Exam or Corrective
    public Intake Intake { get; set; }
    public Branch Branch { get; set; }
    public Track Track { get; set; }
    public Course Course { get; set; }
    public Instructor Instructor { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public int TotalTime { get; set; }
    public string AllowanceOptions { get; set; }
    public List<Question> Questions { get; set; }
    public List<Student> EnrolledStudents { get; set; }

    public Exam(Instructor instructor, Course course, List<Question> questions, DateTime startTime, DateTime endTime)
    {
        Instructor = instructor;
        Course = course;
        Questions = questions;
        StartTime = startTime;
        EndTime = endTime;
        TotalTime = (int)(endTime - startTime).TotalMinutes;
        EnrolledStudents = new List<Student>();
    }
}

public class StudentAnswer
{
    public int AnswerID { get; set; }
    public Student Student { get; set; }
    public Question Question { get; set; }
    public string AnswerText { get; set; }
    public bool IsCorrect { get; set; }
    public int ManualMark { get; set; } // For text questions

    public StudentAnswer(Student student, Question question, string answerText)
    {
        Student = student;
        Question = question;
        AnswerText = answerText;
        IsCorrect = CheckAnswer();
    }

    private bool CheckAnswer()
    {
        // Logic to check answer based on question type
        if (Question.QuestionType == "Text")
            return false; // Manual review needed
        return Question.CorrectAnswer == AnswerText;
    }
}

public class Result
{
    public int ResultID { get; set; }
    public Student Student { get; set; }
    public Exam Exam { get; set; }
    public int TotalMark { get; set; }

    public Result(int resultID, Student student, Exam exam, int totalMark)
    {
        ResultID = resultID;
        Student = student;
        Exam = exam;
        TotalMark = totalMark;
    }
}