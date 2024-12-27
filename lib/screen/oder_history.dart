// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shopmart/screen/edit_order_history';

// class OrderHistoryScreen extends StatefulWidget {
//   @override
//   _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
// }

// class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
//   List<OrderModel> orders = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchOrderHistory();
//   }

//   Future<void> fetchOrderHistory() async {
//     try {
//       final response = await http.get(
//           Uri.parse('http://localhost:5073/api/OrderThTd/GetOrderHistory'));
//       if (response.statusCode == 200) {
//         final List<dynamic> orderList = json.decode(response.body);
//         setState(() {
//           orders = orderList.map((json) => OrderModel.fromJson(json)).toList();
//           isLoading = false;
//         });
//       } else {
//         throw Exception('Failed to load order history');
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching order history: $e')));
//     }
//   }

//   void _editOrder(OrderModel order) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditOrderScreen(order: order),
//       ),
//     );

//     if (result == true) {
//       fetchOrderHistory();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Order History'),
//         backgroundColor: Colors.purple,
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: orders.length,
//               itemBuilder: (context, index) {
//                 final order = orders[index];
//                 return Card(
//                   margin: EdgeInsets.all(8.0),
//                   child: ListTile(
//                     title: Text(
//                       'Order ID: ${order.orderId}',
//                       style: TextStyle(
//                           color: Colors.purple,
//                           fontStyle: FontStyle.italic,
//                           fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Customer ID: ${order.customerId}',
//                         ),
//                         Text('Order Date: ${order.orderDate}'),
//                         ...order.orderDetails.map((detail) => Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('Product Id: ${detail.productId}'),
//                                 Text('Product Name: ${detail.productName}'),
//                                 Text('Quantity: ${detail.quantity}'),
//                                 Text('Total Amount: \$${detail.totalAmount}'),
//                               ],
//                             )),
//                       ],
//                     ),
//                     trailing: IconButton(
//                       icon: Icon(Icons.edit),
//                       onPressed: () => _editOrder(order),
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// class OrderModel {
//   final int orderId;
//   final int customerId;
//   final double netAmount;
//   final String orderDate;
//   final List<OrderDetailModel> orderDetails;

//   OrderModel({
//     required this.orderId,
//     required this.customerId,
//     required this.netAmount,
//     required this.orderDate,
//     required this.orderDetails,
//   });

//   factory OrderModel.fromJson(Map<String, dynamic> json) {
//     return OrderModel(
//       orderId:
//           json['orderID'] ?? 0, // Ensure the key matches the backend response
//       customerId: json['customerId'] ?? 0,
//       netAmount: (json['netAmount'] ?? 0).toDouble(),
//       orderDate: json['orderDate'] ?? '',
//       orderDetails: (json['orderDetails'] as List)
//           .map((i) => OrderDetailModel.fromJson(i))
//           .toList(),
//     );
//   }
// }

// class OrderDetailModel {
//   final int productId;
//   final String productName;
//   final int quantity;
//   final double totalAmount;

//   OrderDetailModel({
//     required this.productId,
//     required this.productName,
//     required this.quantity,
//     required this.totalAmount,
//   });

//   factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
//     return OrderDetailModel(
//       productId: json['productId'] ?? 0,
//       productName: json['productName'] ?? '',
//       quantity: json['quantity'] ?? 0,
//       totalAmount: (json['totalAmount'] ?? 0).toDouble(),
//     );
//   }
// }
