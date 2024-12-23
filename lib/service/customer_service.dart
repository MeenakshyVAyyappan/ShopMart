import 'dart:convert';
import 'package:fcustomerdetails/model/customer_model.dart';
import 'package:http/http.dart' as http;

class ApiServiceCustomer {
  static const String _baseUrl = "http://localhost:5073/api/purchase";

  // POST: Add a new customer
  static Future<bool> addCustomer(CustomerModel customer) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(customer.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Customer added successfully");
        return true;
      } else {
        print("Failed to add customer: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error adding customer: $e");
      return false;
    }
  }
}

class ApiGetCustomer {
  static const String _baseUrl = "http://localhost:5073/api/purchase";

  static Future<List<CustomerModel>> getAllCustomers() async {
    var url = Uri.parse("$_baseUrl");

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map<CustomerModel>((json) {
          return CustomerModel.fromJson(json);
        }).toList();
      } else {
        throw Exception(
            "Failed to fetch customers. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching customers: $e");
    }
  }
}

class ApiDeleteCustomer {
  static const String _baseUrl = "http://localhost:5073/api/purchase";

  // Delete a customer by ID
  static Future<bool> deleteCustomer(int custId) async {
    // Corrected parameter name to 'custId'
    try {
      final response = await http.delete(
        Uri.parse("$_baseUrl/$custId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        print("Customer deleted successfully.");
        return true;
      } else {
        print("Failed to delete customer. Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error deleting customer: $e");
      return false;
    }
  }
}

class APiUpdateCustomer {
  static const String _baseUrl = "http://localhost:5073/api/purchase";
  static updateCustomer(CustomerModel updatedCustomer) async {
    try {
      final response = await http.put(
        Uri.parse("$_baseUrl/${updatedCustomer.custId}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedCustomer.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error updating customer: $e");
      return false;
    }
  }
}
