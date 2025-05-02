import ballerina/http;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as isorecord;
import ballerinax/financial.iso20022 as iso20022;

service / on new http:Listener(9090) {
    resource function post convertToJson(@http:Payload xml xmlPayload) returns json|error {
        record {|anydata...;|}|error parseResult = iso20022:parse(xmlPayload, isorecord:Pacs004Envelope);
        if parseResult is error {
            return error("Failed to parse the XML message");
        }
        
        return parseResult.toJson();
    }

    resource function post convertToMT(@http:Payload xml xmlPayload) returns string|error {
        record {|anydata...;|}|error parseResult = iso20022:parse(xmlPayload, isorecord:Pacs004Envelope);
        if parseResult is error {
            return error("Failed to parse the XML message");
        }

        // Extract required fields from parseResult
        map<anydata> resultMap = <map<anydata>>parseResult;
        map<anydata> appHdr = <map<anydata>>resultMap.get("AppHdr");
        map<anydata> document = <map<anydata>>resultMap.get("Document");
        map<anydata> pmtRtr = <map<anydata>>document.get("PmtRtr");
        isorecord:PaymentTransaction159[] txInfArray = <isorecord:PaymentTransaction159[]>pmtRtr.get("TxInf");
        
        if txInfArray.length() == 0 {
            return error("No transaction information found");
        }

        isorecord:PaymentTransaction159 txInf = txInfArray[0];

        // Format MT message
        string mtMessage = string `{1:F01${checkpanic appHdr.get("Fr").toString()}0000000000}{2:I199${checkpanic appHdr.get("To").toString()}N}{4:
:20:${checkpanic pmtRtr.get("GrpHdr").toString()}
:23B:CRED
:32A:${txInf.IntrBkSttlmDt.toString()}${txInf.RtrdIntrBkSttlmAmt.toString()}
:53A:${txInf.InstgAgt.toString()}
:58A:${txInf.InstdAgt.toString()}
:71A:${txInf.ChrgBr.toString()}
-}`;

        return mtMessage;
    }
}