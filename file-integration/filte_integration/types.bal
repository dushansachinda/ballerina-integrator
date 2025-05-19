type Provider record {|
    decimal billed_charge;
    int[] npi;
|};

type Payment record {|
    decimal allowed_amount;
    Provider[] providers;
|};

type Tin record {|
    string 'type;
    string value;
|};

type AllowedAmount record {|
    Tin tin;
    string[] service_code?;
    string billing_class;
    Payment[] payments;
|};

type OutOfNetworkItem record {|
    string name;
    string billing_code_type;
    string billing_code_type_version;
    string billing_code;
    string description;
    AllowedAmount[] allowed_amounts;
|};

type NetworkData record {|
    string reporting_entity_name;
    string reporting_entity_type;
    string last_updated_on;
    string version;
    OutOfNetworkItem[] out_of_network;
|};

type CsvOutput record {|
    string[][] rows;
|};

type CsvRow record {|
    string name;
    string billing_code;
    string billing_code_type;
    string tin_type;
    string tin_value;
    string billing_class;
    decimal allowed_amount;
    decimal billed_charge;
    string npi;
|};