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
      "custName": custname,
      "custCity": custcity,
      "custPhNumber": custphNumber,
      "custId": custId,
    };
  }

  // Factory constructor to deserialize JSON
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      custname: json["custName"],
      custcity: json["custCity"],
      custId: json['custId'],
      custphNumber: json['custPhNumber'],
    );
  }
}
