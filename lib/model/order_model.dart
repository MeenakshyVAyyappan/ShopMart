// class OrderModel {
//   int ProductId;
//   int Quantity;
//   int TotalAmount;
//   String ProductName;

//   OrderModel({
//     this.ProductId = 0,
//     this.Quantity = 0,
//     this.TotalAmount = 0,
//     required this.ProductName,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       "productname": ProductName,
//       "pid": ProductId, // Removed null coalescing operator
//       "Quantity": Quantity,
//       "TotalAmount": TotalAmount,
//     };
//   }

//   factory OrderModel.fromJson(Map<String, dynamic> json) {
//     return OrderModel(
//       ProductId: json["pid"],
//       Quantity: json["Quantity"],
//       TotalAmount: json["TotalAmount"],
//       ProductName: json["ProductName"],
//     );
//   }
// }
