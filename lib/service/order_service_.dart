// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shopmart/model/order_model.dart';

// class ApiCreateOrder {
//   static const String _baseUrl =
//       "http://localhost:5073/api/OrderThTd/CreateOrder";

//   static Future<bool> addProduct(OrderModel order) async {
//     try {
//       final response = await http.post(
//         Uri.parse(_baseUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(order.toJson()),
//       );

//       if (response.statusCode == 200) {
//         return true; // Order successfully added
//       } else {
//         throw Exception("Failed to add order: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error: $e");
//       return false;
//     }
//   }
// }
