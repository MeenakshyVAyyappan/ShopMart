class ProductModel {
  int? productid;
  String? productname;
  int? productMRP;
  int? productstock;
  String? imageUrl;

  ProductModel({
    this.productid,
    this.productname,
    this.productMRP,
    this.productstock,
    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    print("Parsing Product: $json");
    return ProductModel(
      productid: json['prdtid'],
      productname: json['prdtname'],
      productMRP: json['prdtmrp'],
      productstock: json['prdtstock'],
      imageUrl: json['imageurl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prdtid': productid,
      'prdtname': productname,
      'prdtmrp': productMRP,
      'prdtstock': productstock,
    };
  }
}
