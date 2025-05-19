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
    pollingInterval: 5,
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
            log:printInfo("Reading file file #1");
            stream<byte[] & readonly, io:Error?> fileStream = check caller->get(addedFile.pathDecoded);
            byte[] content = [];
            check from byte[] chunk in fileStream
                do {
                    content.push(...chunk);
                };
            check fileStream.close();

            string jsonString = check string:fromBytes(content);
            json jsonContent = check value:fromJsonString(jsonString);
            NetworkData networkData = check value:cloneWithType(jsonContent);

            log:printInfo("Reading file transforming to CSV #2");
            CsvOutput csvOutput = transformToCsvRecords(networkData);
            log:printInfo("Reading file transforming to CSV #2 done!!");

            string csvContent = string:'join("\n", ...csvOutput.rows.map(row => string:'join(",", ...row)));

            ftp:Error? mkdirResult = sftpClient->mkdir(sftpOutputPath);
            if mkdirResult is ftp:Error {
                log:printInfo("Directory might already exist: " + mkdirResult.message());
            }

            string csvFileName = addedFile.name + ".csv";
            string remotePath = string `${sftpOutputPath}/${csvFileName}`;
            check sftpClient->put(path = remotePath, content = csvContent);
            log:printInfo("CSV file uploaded to SFTP: " + remotePath);
        }
    }
}