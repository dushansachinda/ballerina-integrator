import ballerina/lang.value;

function transformToCsvRecords(json jsonContent) returns string[][]|error {
    NetworkData data = check value:cloneWithType(jsonContent);
    string[][] csvRecords = [];
    
    // Add headers
    csvRecords.push(["Name", "Billing Code", "Billing Code Type", "TIN Type", "TIN Value", 
        "Billing Class", "Allowed Amount", "Billed Charge", "NPI"]);

    foreach OutOfNetworkItem item in data.out_of_network {
        foreach AllowedAmount allowedAmount in item.allowed_amounts {
            foreach Payment payment in allowedAmount.payments {
                foreach Provider provider in payment.providers {
                    foreach int npiValue in provider.npi {
                        string[] row = [
                            item.name,
                            item.billing_code,
                            item.billing_code_type,
                            allowedAmount.tin.'type,
                            allowedAmount.tin.value,
                            allowedAmount.billing_class,
                            payment.allowed_amount.toString(),
                            provider.billed_charge.toString(),
                            npiValue.toString()  // Convert int to string for CSV
                        ];
                        csvRecords.push(row);
                    }
                }
            }
        }
    }
    return csvRecords;
}