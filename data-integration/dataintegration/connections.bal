
import ballerinax/mysql;
import ballerina/http;

final mysql:Client dbClient = check new(
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


final http:Client studentClient =check new("http://localhost:8081");
final http:Client academicClient = check new("http://localhost:8082");
