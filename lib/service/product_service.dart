import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopmart/model/product_model.dart';

class ApiServiceProduct {
  static const String _baseUrl = "http://localhost:5073/api/product";

  static Future<List<ProductModel>> fetchProducts() async {
    final url = Uri.parse("$_baseUrl");
    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map<ProductModel>((json) {
          return ProductModel.fromJson(json);
        }).toList();
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  // Implementing the addProduct method
  static Future<bool> addProduct(ProductModel newProduct) async {
    final url = Uri.parse("$_baseUrl");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newProduct.toJson()),
      );

      // Handle success based on both 200 and 201 status codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Success: ${response.body}");
        return true; // Success
      } else {
        // Log error details for debugging
        print("Error: ${response.statusCode} - ${response.body}");
        return false; // Failure
      }
    } catch (e) {
      // Catch and log exceptions
      print("Exception occurred while adding product: $e");
      return false; // Failure
    }
  }
}
