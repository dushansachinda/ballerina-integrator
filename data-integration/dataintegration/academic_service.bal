import ballerina/http;
import ballerinax/mysql;
import ballerina/sql;

// Database configurations
configurable string dbHost = "localhost";
configurable string dbUser = "root";
configurable string dbPassword = "root";
configurable string dbName = "Company";
configurable int dbPort = 3306;
configurable record {|
    string serverTimezone;
    decimal socketTimeout;
    boolean noAccessToProcedureBodies;
    boolean useXADatasource;
|} dbOptions = {
    serverTimezone: "UTC",
    socketTimeout: 30.0,
    noAccessToProcedureBodies: false,
    useXADatasource: false
};
// Academic Program Service
service /academic on new http:Listener(8082) {
    private final mysql:Client dbClient;

    function init() returns error? {
        self.dbClient = check new(
            host = dbHost,
            user = dbUser,
            password = dbPassword,
            database = dbName,
            port = dbPort,
            options = {
                serverTimezone: dbOptions.serverTimezone,
                socketTimeout: dbOptions.socketTimeout,
                noAccessToProcedureBodies: dbOptions.noAccessToProcedureBodies,
                useXADatasource: dbOptions.useXADatasource
            }
        );
    }

    resource function get programs/[int studentId](string department) returns AcademicProgram[]|error {
        stream<AcademicProgram, sql:Error?> resultStream = self.dbClient->query(
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