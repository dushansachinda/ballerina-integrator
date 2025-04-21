// Function to map student info and academic programs to consolidated student details
public function mapToStudentDetails(StudentInfo studentInfo, AcademicProgram[] programs) returns StudentDetails => {
    studentId: studentInfo.studentId,
    firstName: studentInfo.firstName,
    lastName: studentInfo.lastName,
    personalEmail: studentInfo.personalEmail,
    programs: programs
};