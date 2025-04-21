import ballerina/http;
import ballerina/sql;



// Academic Program Service
service /academic on new http:Listener(8082) {

    resource function get programs/[int studentId](string department) returns AcademicProgram[]|error {
        stream<AcademicProgram, sql:Error?> resultStream = dbClient->query(
            `SELECT p.* FROM AcademicPrograms p
             INNER JOIN StudentPrograms sp ON p.programId = sp.programId
             WHERE sp.studentId = ${studentId}
             AND p.department = ${department}`
        );

        AcademicProgram[] programs = [];
        check from AcademicProgram program in resultStream
            do {
                programs.push(program);
            };
        return programs;
    }
}