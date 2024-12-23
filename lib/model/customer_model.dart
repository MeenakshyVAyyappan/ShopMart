class CustomerModel {
  int? custId;
  String? custname;
  String? custcity;
  String? custphNumber;

  CustomerModel(
      {required this.custname,
      required this.custcity,
      this.custId,
      required this.custphNumber});

  Map<String, dynamic> toJson() {
    return {
      "CUSTNAME": custname,
      "CUSTCITY": custcity,
      "CUSTPHNUMBER": custphNumber,
      "CUSTID": custId,
    };
  }

  // Factory constructor to deserialize JSON
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      custname: json["CUSTNAME"] ?? 'No Name',
      custcity: json["CUSTCITY"] ?? 'No City',
      custId: json['CUSTID'],
      custphNumber: json['CUSTPHNUMBER'] ?? 'No Phone Number',
    );
  }
}
