import ballerina/http;
import ballerina/log;
//import ballerinax/wso2.apim.catalog as _;


// Consolidated Service that combines data from both services
service /consolidate on new http:Listener(8080) {


    resource function get students/[int studentId](string department) returns StudentDetails|error {
        // Get student info from student service
        StudentInfo studentInfo = check studentClient->/studentinfo/students/[studentId];
       
        log:printInfo("info log #1", id = studentInfo.studentId, name = studentInfo.firstName);
        log:printInfo("info log #2 department", id = department);

        // Get academic programs from academic service
        AcademicProgram[] programs = check academicClient->/academic/programs/[studentId].get(headers = {}, department = department);

        // Use the mapper to consolidate the data
        return mapToStudentDetails(studentInfo, programs);
    }
}