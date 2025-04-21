import ballerina/http;
import ballerina/log;
//import ballerinax/wso2.apim.catalog as _;


// Consolidated Service that combines data from both services
service /consolidate on new http:Listener(8080) {
    private final http:Client studentClient;
    private final http:Client academicClient;

    

    function init() returns error? {
        self.studentClient = check new("http://localhost:8081");
        self.academicClient = check new("http://localhost:8082");
    }

    resource function get students/[int studentId](string department) returns StudentDetails|error {
        // Get student info from student service
        StudentInfo studentInfo = check self.studentClient->/studentinfo/students/[studentId];
       
        log:printInfo("info log #1", id = studentInfo.studentId, name = studentInfo.firstName);
        log:printInfo("info log #2 department", id = department);

        // Get academic programs from academic service
        AcademicProgram[] programs = check self.academicClient->/academic/programs/[studentId].get(headers = {}, department = department);

        // Use the mapper to consolidate the data
        return mapToStudentDetails(studentInfo, programs);
    }
}