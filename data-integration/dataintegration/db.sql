-- Academic Program table
CREATE TABLE AcademicPrograms (
    programId INT PRIMARY KEY,
    programName VARCHAR(100),
    department VARCHAR(100)
);

-- Student Personal Info table
CREATE TABLE StudentInfo (
    studentId INT PRIMARY KEY,
    firstName VARCHAR(50),
    lastName VARCHAR(50),
    personalEmail VARCHAR(100)
);

-- Student Program Enrollment table
CREATE TABLE StudentPrograms (
    studentId INT,
    programId INT,
    enrollmentDate DATE,
    FOREIGN KEY (studentId) REFERENCES StudentInfo(studentId),
    FOREIGN KEY (programId) REFERENCES AcademicPrograms(programId)
);

-- Insert sample data
INSERT INTO AcademicPrograms VALUES 
(1, 'Computer Science', 'Engineering'),
(2, 'Business Administration', 'Business');

INSERT INTO StudentInfo VALUES
(101, 'John', 'Doe', 'john.doe@personal.com'),
(102, 'Jane', 'Smith', 'jane.smith@personal.com');

INSERT INTO StudentPrograms VALUES
(101, 1, '2023-01-01'),
(102, 2, '2023-01-01');