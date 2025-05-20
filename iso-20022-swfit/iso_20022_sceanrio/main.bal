//import ballerina/ftp;
import ballerina/http;
//import ballerina/io;
import ballerina/log;
import ballerinax/financial.iso20022 as iso20022;
import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;

//import ballerinax/financial.iso20022.cash_management as camtIsoRecord;

// final ftp:ListenerConfiguration listenerConfig = {
//     protocol: ftp:SFTP,
//     host: sftpHost,
//     port: sftpPort,
//     path: sftpPath,
//     pollingInterval: 5,
//     fileNamePattern: fileNamePattern,
//     auth: {
//         credentials: {
//             username: sftpUsername,
//             password: sftpPassword
//         }
//     }
// };

// listener ftp:Listener fileListener = check new (listenerConfig);

// service on fileListener {
//     remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {
//         log:printInfo("Reading file file #1");
//         foreach ftp:FileInfo addedFile in event.addedFiles {
//             log:printInfo("Reading file file #1");

//             stream<byte[] & readonly, io:Error?> fileStream = check caller->get(addedFile.pathDecoded);
//             byte[] content = [];
//             check from byte[] chunk in fileStream
//                 do {
//                     content.push(...chunk);
//                 };
//             check fileStream.close();

//             string fileContent = check string:fromBytes(content);
//             xml|error xmlContent = xml:fromString(fileContent);
//             if xmlContent is error {
//                 log:printError("Invalid XML content", xmlContent);
//                 continue;
//             }

//             ValidationResult|error validationResult = check validatePain001Message(xmlContent);
//             if validationResult is error {
//                 log:printError("Validation failed", validationResult);
//                 continue;
//             }

//             if !validationResult.isValid {
//                 log:printError("Validation failed", errors = validationResult.errors);
//                 continue;
//             }
//         }
//     }
// }

service / on new http:Listener(9090) {
    resource function post validatePain001(@http:Payload xml xmlPayload) returns ValidationResult|error {
        return validatePain001Message(xmlPayload);
    }
}

function validatePain001Message(xml xmlContent) returns ValidationResult|error {
    record {|anydata...;|}|error parseResult = iso20022:parse(xmlContent, painIsoRecord:Pain001Envelope);
    if parseResult is error {
        return {
            isValid: false,
            errors: ["Invalid pain.001 format: " + parseResult.message()]
        };
    }

    log:printInfo("Parsed pain.001 message #1", test = parseResult);

    string[] errors = [];

    painIsoRecord:Pain001Envelope envelope = check parseResult.ensureType();
    log:printInfo("Parsed pain.001 message #2", test = envelope);
    painIsoRecord:CustomerCreditTransferInitiationV12 custCdtTrfInitn = envelope.Document.CstmrCdtTrfInitn;
    log:printInfo("Parsed pain.001 message #3", test = custCdtTrfInitn);
    painIsoRecord:PaymentInstruction44[] pmtInfArray = custCdtTrfInitn.PmtInf;
    log:printInfo("Parsed pain.001 message #4", test = pmtInfArray);
    log:printInfo("Parsed pain.001 message #5 length $$$$", test = pmtInfArray.length());
     if pmtInfArray.length() == 0 {
        return {
            isValid: false,
            errors: ["No payment information found in the message"]
        };
    }

    // Validate each payment instruction
     // Get the first payment's execution date as reference
    painIsoRecord:DateAndDateTime2Choice firstExctnDt = pmtInfArray[0].ReqdExctnDt;
    string grpReqdExctnDt = firstExctnDt.Dt.toString();
    log:printInfo("Parsed pain.001 message #6-0 payment grpReqdExctnDt ...", test = grpReqdExctnDt);

    // Validate all payments have same execution date
    foreach painIsoRecord:PaymentInstruction44 pmtInf in pmtInfArray {
        painIsoRecord:DateAndDateTime2Choice paymentExctnDt = pmtInf.ReqdExctnDt;
        string paymentDate = paymentExctnDt.Dt.toString();
         log:printInfo("Parsed pain.001 message #6-1 payment INFO ...", test = pmtInf);
        log:printInfo("Parsed pain.001 message #6-2 payment date is ...", test = paymentDate);
        
        if paymentDate != grpReqdExctnDt {
            errors.push(string `Execution date mismatch: ${paymentDate} != ${grpReqdExctnDt}`);
        }

        // Get currency and validate exchange rate exists
        foreach painIsoRecord:CreditTransferTransaction61 cdtTrfTxInf in pmtInf.CdtTrfTxInf {
            painIsoRecord:AmountType4Choice amt = cdtTrfTxInf.Amt;
            painIsoRecord:ActiveOrHistoricCurrencyAndAmount? instdAmt = amt.InstdAmt;

            log:printInfo("Parsed pain.001 message #6", test = instdAmt);
            
            if instdAmt is painIsoRecord:ActiveOrHistoricCurrencyAndAmount {
                string currency = instdAmt.Ccy;

                boolean exchangeRateExists = exchangeRates.some(rate =>
                    rate.currency == currency && rate.valueDate == paymentDate);
                if !exchangeRateExists {
                    errors.push(string `No exchange # rate found for currency ${currency} on date ${paymentDate}`);
                }
            } else {
                errors.push("Missing instructed amount in transaction");
            }
        }
    }



    return {
        isValid: errors.length() == 0,
        errors: errors
    };
}
