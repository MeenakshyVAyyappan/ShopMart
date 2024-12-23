class ProductModel {
  String productname;
  int? productMRP;
  int? productid;
  int? productstock;

  ProductModel({
    required this.productname,
    required this.productMRP,
    this.productid,
    required this.productstock,
  });

  Map<String, dynamic> toJson() {
    return {
      "PRDTNAME": productname,
      "PRDTMRP": productMRP ?? 0,
      "PRDTID": productid ?? 0,
      "PRDTSTOCK": productstock ?? 0,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productname: json["PRDTNAME"] ?? "Unknown Product",
      productMRP: json["PRDTMRP"] ?? 0,
      productid: json["PRDTID"],
      productstock: json["PRDTSTOCK"] ?? 0,
    );
  }
}
