// Student Info Service Types
type StudentInfo record {|
    int studentId;
    string firstName;
    string lastName;
    string personalEmail;
|};

// Academic Program Service Types
type AcademicProgram record {|
    int programId;
    string programName;
    string department;
|};

// Consolidated Service Types
type StudentDetails record {|
    int studentId;
    string firstName;
    string lastName;
    string personalEmail;
    AcademicProgram[] programs;
|};