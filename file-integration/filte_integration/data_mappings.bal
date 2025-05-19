function transformToCsvRecords(NetworkData data) returns CsvOutput => {
    rows: [
        ["Name", "Billing Code", "Billing Code Type", "TIN Type", "TIN Value", 
            "Billing Class", "Allowed Amount", "Billed Charge", "NPI"],
        ...from OutOfNetworkItem item in data.out_of_network
            from AllowedAmount allowedAmount in item.allowed_amounts
            from Payment payment in allowedAmount.payments
            from Provider provider in payment.providers
            from int npiValue in provider.npi
            select [
                item.name,
                item.billing_code,
                item.billing_code_type,
                allowedAmount.tin.'type,
                allowedAmount.tin.value,
                allowedAmount.billing_class,
                payment.allowed_amount.toString(),
                provider.billed_charge.toString(),
                npiValue.toString()
            ]
    ]
};