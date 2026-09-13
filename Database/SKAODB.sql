-- =========================================================
-- CertPath Database Schema
-- =========================================================

CREATE DATABASE SKAODB;
GO
USE SKAODB;
GO

-- ---------- Users ----------
CREATE TABLE Users (
    UserID          INT IDENTITY(1,1) PRIMARY KEY,
    FullName        NVARCHAR(100)   NOT NULL,
    Email           NVARCHAR(150)   NOT NULL UNIQUE,
    PasswordHash    NVARCHAR(255)   NOT NULL,
    Role            NVARCHAR(20)    NOT NULL CHECK (Role IN ('Member','Admin')),
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE()
);

-- ---------- Career Paths ----------
CREATE TABLE CareerPaths (
    PathID          INT IDENTITY(1,1) PRIMARY KEY,
    PathName        NVARCHAR(100)   NOT NULL,       -- e.g. Penetration Tester
    Description     NVARCHAR(MAX)   NULL,
    ImageUrl        NVARCHAR(255)   NULL
);

-- ---------- Certifications ----------
CREATE TABLE Certifications (
    CertID          INT IDENTITY(1,1) PRIMARY KEY,
    CertName        NVARCHAR(100)   NOT NULL,       -- e.g. Security+, OSCP
    Provider        NVARCHAR(100)   NULL,           -- e.g. CompTIA, OffSec
    Level           NVARCHAR(20)    NOT NULL CHECK (Level IN ('Beginner','Intermediate','Advanced')),
    Description     NVARCHAR(MAX)   NULL,
    Website         NVARCHAR(255)   NULL
);

-- ---------- Junction: which certs belong to which path, in what order ----------
CREATE TABLE PathCertifications (
    PathCertID      INT IDENTITY(1,1) PRIMARY KEY,
    PathID          INT NOT NULL FOREIGN KEY REFERENCES CareerPaths(PathID),
    CertID          INT NOT NULL FOREIGN KEY REFERENCES Certifications(CertID),
    StepOrder       INT NOT NULL,                   
    IsOptional      BIT NOT NULL DEFAULT 0
);

-- ---------- Learning Resources (linked to a cert) ----------
CREATE TABLE Resources (
    ResourceID      INT IDENTITY(1,1) PRIMARY KEY,
    CertID          INT NOT NULL FOREIGN KEY REFERENCES Certifications(CertID),
    Title           NVARCHAR(150)   NOT NULL,
    ResourceType    NVARCHAR(30)    NOT NULL CHECK (ResourceType IN ('Course','Book','Video','Lab','Article')),
    Url             NVARCHAR(255)   NULL
);

-- ---------- Member progress tracking ----------
CREATE TABLE UserProgress (
    ProgressID      INT IDENTITY(1,1) PRIMARY KEY,
    UserID          INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    CertID          INT NOT NULL FOREIGN KEY REFERENCES Certifications(CertID),
    Status          NVARCHAR(20)    NOT NULL CHECK (Status IN ('NotStarted','InProgress','Completed')) DEFAULT 'NotStarted',
    UpdatedAt       DATETIME        NOT NULL DEFAULT GETDATE()
);

-- ---------- Self-assessment quizzes (per path) ----------
CREATE TABLE Quizzes (
    QuizID          INT IDENTITY(1,1) PRIMARY KEY,
    PathID          INT NOT NULL FOREIGN KEY REFERENCES CareerPaths(PathID),
    Title           NVARCHAR(150)   NOT NULL
);

CREATE TABLE QuizQuestions (
    QuestionID      INT IDENTITY(1,1) PRIMARY KEY,
    QuizID          INT NOT NULL FOREIGN KEY REFERENCES Quizzes(QuizID),
    QuestionText    NVARCHAR(MAX)   NOT NULL,
    OptionA         NVARCHAR(255)   NOT NULL,
    OptionB         NVARCHAR(255)   NOT NULL,
    OptionC         NVARCHAR(255)   NULL,
    OptionD         NVARCHAR(255)   NULL,
    CorrectOption   CHAR(1)         NOT NULL CHECK (CorrectOption IN ('A','B','C','D'))
);

CREATE TABLE QuizResults (
    ResultID        INT IDENTITY(1,1) PRIMARY KEY,
    UserID          INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    QuizID          INT NOT NULL FOREIGN KEY REFERENCES Quizzes(QuizID),
    Score           INT NOT NULL,
    TakenAt         DATETIME NOT NULL DEFAULT GETDATE()
);

-- ---------- Discussion board (per path) ----------
CREATE TABLE DiscussionPosts (
    PostID          INT IDENTITY(1,1) PRIMARY KEY,
    PathID          INT NOT NULL FOREIGN KEY REFERENCES CareerPaths(PathID),
    UserID          INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    Title           NVARCHAR(150)   NOT NULL,
    Body            NVARCHAR(MAX)   NOT NULL,
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE()
);

-- =========================================================
-- Seed Data: the 4 launch career paths
-- =========================================================
INSERT INTO CareerPaths (PathName, Description) VALUES
('Penetration Tester', 'Offensive security specialists who find and exploit vulnerabilities before attackers do.'),
('Red Team Operator', 'Simulates real-world adversary campaigns to test an organisation''s full defensive posture.'),
('SOC Analyst', 'Monitors, detects, and responds to security incidents from within a Security Operations Center.'),
('Threat Hunter', 'Proactively searches networks and systems for hidden threats that evade automated detection.');

-- Example certifications (expand as needed)
INSERT INTO Certifications (CertName, Provider, Level, Description) VALUES
('CompTIA Security+', 'CompTIA', 'Beginner', 'Foundational cybersecurity certification covering core security concepts.'),
('eJPT', 'INE', 'Beginner', 'Entry-level practical penetration testing certification.'),
('OSCP', 'OffSec', 'Advanced', 'Hands-on offensive security certification focused on penetration testing.'),
('GCIH', 'GIAC', 'Intermediate', 'Incident handling and response certification.'),
('CEH', 'EC-Council', 'Intermediate', 'Certified Ethical Hacker, covers hacking tools and methodology.'),
('GCTI', 'GIAC', 'Advanced', 'Cyber threat intelligence certification for threat hunters/analysts.');

-- Example roadmap ordering: Penetration Tester path (PathID = 1)
INSERT INTO PathCertifications (PathID, CertID, StepOrder) VALUES
(1, 1, 1),  -- Security+
(1, 2, 2),  -- eJPT
(1, 3, 3);  -- OSCP

-- SOC Analyst path (PathID = 3)
INSERT INTO PathCertifications (PathID, CertID, StepOrder) VALUES
(3, 1, 1),  -- Security+
(3, 4, 2);  -- GCIH

-- Threat Hunter path (PathID = 4)
INSERT INTO PathCertifications (PathID, CertID, StepOrder) VALUES
(4, 1, 1),  -- Security+
(4, 4, 2),  -- GCIH
(4, 6, 3);  -- GCTI
