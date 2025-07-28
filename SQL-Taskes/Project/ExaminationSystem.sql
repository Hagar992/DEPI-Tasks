-- Creating the Examination System Database
CREATE DATABASE ExaminationSystem;
GO

USE ExaminationSystem;
GO

-- Table for Users 
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) UNIQUE NOT NULL,
    Password NVARCHAR(100) NOT NULL,
    UserType NVARCHAR(20) NOT NULL CHECK (UserType IN ('Admin', 'TrainingManager', 'Instructor', 'Student')),
    Email NVARCHAR(100) UNIQUE NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Table for Branches
CREATE TABLE Branches (
    BranchID INT PRIMARY KEY IDENTITY(1,1),
    BranchName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500)
);

-- Table for Tracks
CREATE TABLE Tracks (
    TrackID INT PRIMARY KEY IDENTITY(1,1),
    BranchID INT NOT NULL,
    TrackName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);

-- Table for Intakes
CREATE TABLE Intakes (
    IntakeID INT PRIMARY KEY IDENTITY(1,1),
    IntakeYear INT NOT NULL,
    Description NVARCHAR(500)
);

-- Table for Courses
CREATE TABLE Courses (
    CourseID INT PRIMARY KEY IDENTITY(1,1),
    CourseName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    MaxDegree DECIMAL(5,2) NOT NULL,
    MinDegree DECIMAL(5,2) NOT NULL,
    CHECK (MaxDegree > MinDegree)
);

-- Table for Instructors_Courses 
CREATE TABLE Instructors_Courses (
    InstructorID INT NOT NULL,
    CourseID INT NOT NULL,
    AcademicYear INT NOT NULL,
    PRIMARY KEY (InstructorID, CourseID, AcademicYear),
    FOREIGN KEY (InstructorID) REFERENCES Users(UserID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

-- Table for Students
CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    IntakeID INT NOT NULL,
    BranchID INT NOT NULL,
    TrackID INT NOT NULL,
    FOREIGN KEY (StudentID) REFERENCES Users(UserID),
    FOREIGN KEY (IntakeID) REFERENCES Intakes(IntakeID),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (TrackID) REFERENCES Tracks(TrackID)
);

-- Table for Question Pool
CREATE TABLE QuestionPool (
    QuestionID INT PRIMARY KEY IDENTITY(1,1),
    CourseID INT NOT NULL,
    QuestionText NVARCHAR(MAX) NOT NULL,
    QuestionType NVARCHAR(20) NOT NULL CHECK (QuestionType IN ('MultipleChoice', 'TrueFalse', 'Text')),
    CorrectAnswer NVARCHAR(MAX),
    BestAnswer NVARCHAR(MAX), 
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

-- Table for Exams
CREATE TABLE Exams (
    ExamID INT PRIMARY KEY IDENTITY(1,1),
    CourseID INT NOT NULL,
    InstructorID INT NOT NULL,
    ExamType NVARCHAR(20) NOT NULL CHECK (ExamType IN ('Exam', 'Corrective')),
    IntakeID INT NOT NULL,
    BranchID INT NOT NULL,
    TrackID INT NOT NULL,
    AcademicYear INT NOT NULL,
    StartTime DATETIME NOT NULL,
    EndTime DATETIME NOT NULL,
    TotalTime INT NOT NULL, -- In minutes
    AllowanceOptions NVARCHAR(500),
    TotalDegree DECIMAL(5,2) NOT NULL,
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    FOREIGN KEY (InstructorID) REFERENCES Users(UserID),
    FOREIGN KEY (IntakeID) REFERENCES Intakes(IntakeID),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    FOREIGN KEY (TrackID) REFERENCES Tracks(TrackID),
    CHECK (EndTime > StartTime)
);
GO

-- Trigger to check TotalDegree against MaxDegree in Courses
CREATE TRIGGER TRG_Exams_CheckTotalDegree
ON Exams
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if TotalDegree exceeds MaxDegree for any inserted/updated exam
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Courses c ON i.CourseID = c.CourseID
        WHERE i.TotalDegree > c.MaxDegree
    )
    BEGIN
        RAISERROR ('TotalDegree cannot exceed MaxDegree of the Course.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO
-- Table for Exam Questions
CREATE TABLE Exam_Questions (
    ExamID INT NOT NULL,
    QuestionID INT NOT NULL,
    QuestionDegree DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (ExamID, QuestionID),
    FOREIGN KEY (ExamID) REFERENCES Exams(ExamID),
    FOREIGN KEY (QuestionID) REFERENCES QuestionPool(QuestionID),
    CHECK (QuestionDegree > 0)
);

-- Table for Exam Students 
CREATE TABLE Exam_Students (
    ExamID INT NOT NULL,
    StudentID INT NOT NULL,
    PRIMARY KEY (ExamID, StudentID),
    FOREIGN KEY (ExamID) REFERENCES Exams(ExamID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
);

-- Table for Student Answers
CREATE TABLE Student_Answers (
    ExamID INT NOT NULL,
    StudentID INT NOT NULL,
    QuestionID INT NOT NULL,
    StudentAnswer NVARCHAR(MAX) NOT NULL,
    IsCorrect BIT, -- For MCQ and TrueFalse
    ManualMark DECIMAL(5,2), 
    PRIMARY KEY (ExamID, StudentID, QuestionID),
    FOREIGN KEY (ExamID) REFERENCES Exams(ExamID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (QuestionID) REFERENCES QuestionPool(QuestionID)
);

-- Table for Results
CREATE TABLE Results (
    ResultID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    ExamID INT NOT NULL,
    TotalMark DECIMAL(5,2) NOT NULL,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    FOREIGN KEY (ExamID) REFERENCES Exams(ExamID)
);

--  performance
CREATE INDEX IX_Students_IntakeID ON Students(IntakeID);
CREATE INDEX IX_Students_BranchID ON Students(BranchID);
CREATE INDEX IX_Students_TrackID ON Students(TrackID);
CREATE INDEX IX_QuestionPool_CourseID ON QuestionPool(CourseID);
CREATE INDEX IX_Exams_CourseID ON Exams(CourseID);
CREATE INDEX IX_Exams_InstructorID ON Exams(InstructorID);
CREATE INDEX IX_Exam_Students_StudentID ON Exam_Students(StudentID);
CREATE INDEX IX_Student_Answers_StudentID ON Student_Answers(StudentID);
CREATE INDEX IX_Results_StudentID ON Results(StudentID);