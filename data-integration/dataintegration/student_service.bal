import ballerina/http;

// Student Info Service
service /studentinfo on new http:Listener(8081) {

    resource function get students/[int studentId]() returns StudentInfo|error {
        return check dbClient->queryRow(
            `SELECT * FROM StudentInfo WHERE studentId = ${studentId}`
        );
    }
}