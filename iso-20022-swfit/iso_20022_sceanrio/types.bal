type ValidationResult record {|
    boolean isValid;
    string[] errors;
|};

type ExchangeRate record {|
    string currency;
    string valueDate;
    decimal rate;
|};

// Mock exchange rates (In real implementation, this would come from a database)
final readonly & ExchangeRate[] exchangeRates = [
    {currency: "EUR", valueDate: "2025-05-21", rate: 1.08},
    {currency: "GBP", valueDate: "2025-05-21", rate: 1.26}
];