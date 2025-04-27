import ballerina/ftp;
import ballerina/io;
import ballerina/lang.value;
import ballerina/log;

configurable string sftpHost = "";
configurable int sftpPort = 22;
configurable string sftpUsername = "";
configurable string sftpPassword = "";
configurable string sftpPath = "";
configurable string sftpOutputPath = "";
configurable string fileNamePattern = "";

final ftp:ClientConfiguration sftpConfig = {
    protocol: ftp:SFTP,
    host: sftpHost,
    port: sftpPort,
    auth: {
        credentials: {
            username: sftpUsername,
            password: sftpPassword
        }
    }
};

final ftp:Client sftpClient = check new (sftpConfig);

final ftp:ListenerConfiguration listenerConfig = {
    protocol: ftp:SFTP,
    host: sftpHost,
    port: sftpPort,
    path: sftpPath,
    fileNamePattern: fileNamePattern,
    auth: {
        credentials: {
            username: sftpUsername,
            password: sftpPassword
        }
    }
};

listener ftp:Listener fileListener = check new (listenerConfig);

service on fileListener {
    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {
        foreach ftp:FileInfo addedFile in event.addedFiles {
            // Read and process JSON file directly from stream
            stream<byte[] & readonly, io:Error?> fileStream = check caller->get(addedFile.pathDecoded);
            byte[] content = [];
            check from byte[] chunk in fileStream
                do {
                    content.push(...chunk);
                };
            check fileStream.close();

            // Convert byte array to JSON and process
            string jsonString = check string:fromBytes(content);
            json jsonContent = check value:fromJsonString(jsonString);
            string[][] csvRecords = check transformToCsvRecords(jsonContent);

            // Convert CSV records to string content
            string csvContent = string:'join("\n", ...csvRecords.map(row => string:'join(",", ...row)));

            // Create directory if not exists (ignore errors)
            ftp:Error? mkdirResult = sftpClient->mkdir(sftpOutputPath);
            if mkdirResult is ftp:Error {
                log:printInfo("Directory might already exist: " + mkdirResult.message());
            }

            // Upload CSV directly to SFTP
            string csvFileName = addedFile.name + ".csv";
            string remotePath = string `${sftpOutputPath}/${csvFileName}`;
            check sftpClient->put(path = remotePath, content = csvContent);
            log:printInfo("CSV file uploaded to SFTP: " + remotePath);
        }
    }
}