import ballerina/http;
import ballerinax/salesforce;

// Initialize Salesforce client
salesforce:ConnectionConfig config = {
    baseUrl: baseUrl,
    auth: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshToken: refreshToken,
        refreshUrl: refreshUrl
    }
};

salesforce:Client salesforceEp = check new (config);

// Create HTTP service to expose Salesforce operations
service / on new http:Listener(8080) {

    // Resource to get account by ID
    resource function get accounts/[string accountId]() returns Account|error {
        // Get account from Salesforce
        Account account = check salesforceEp->getById("Account", accountId, Account);
        return account;
    }
}