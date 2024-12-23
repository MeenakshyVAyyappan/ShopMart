import 'dart:convert';
import 'package:fcustomerdetails/model/product_model.dart';
import 'package:http/http.dart' as http;

class ApiServiceProduct {
  static const String _baseUrl = "http://localhost:5073/api/product";

  static Future<bool> addProduct(ProductModel product) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Failed to add product: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}

class ApiGetProduct {
  static const String _baseUrl = "http://localhost:5073/api/product";

  static Future<List<ProductModel>> fetchProducts() async {
    var url = Uri.parse("$_baseUrl");
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
}
