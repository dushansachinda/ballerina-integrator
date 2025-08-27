import ballerina/http;
import ballerinax/salesforce;

// Initialize Salesforce client as final to make it immutable
salesforce:ConnectionConfig config = {
    baseUrl: baseUrl,
    auth: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshToken: refreshToken,
        refreshUrl: refreshUrl
    }
};

final salesforce:Client salesforceEp = check new (config);

// Create HTTP service to expose Salesforce operations
service / on new http:Listener(8080) {

    // Resource to get account by ID
    isolated resource function get accounts/[string accountId]() returns Account|error {
        // Get account from Salesforce
        Account account = check salesforceEp->getById(sobjectName = "Account", id = accountId, returnType = Account);
        return account;
    }
}