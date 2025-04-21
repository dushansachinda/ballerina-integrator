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