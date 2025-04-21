import ballerina/http;
import ballerinax/mysql;

// Student Info Service
service /studentinfo on new http:Listener(8081) {
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

    resource function get students/[int studentId]() returns StudentInfo|error {
        return check self.dbClient->queryRow(
            `SELECT * FROM StudentInfo WHERE studentId = ${studentId}`
        );
    }
}