import 'dart:convert';
import 'dart:io';
import 'dart:ui'; // Import for BackdropFilter
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopmart/model/customer_model.dart';
import 'package:shopmart/model/product_model.dart';
import 'package:shopmart/service/customer_service.dart';
import 'package:shopmart/service/product_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];
  List<CustomerModel> customers = [];
  String? selectedCustomer;
  bool isLoading = true;
  Map<int, int> productQuantities = {};
  Set<int> selectedProducts = {};
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCustomers();
    _searchController.addListener(_filterProducts);
  }

  Future<void> fetchProducts() async {
    try {
      final fetchedProducts = await ApiServiceProduct.fetchProducts();
      setState(() {
        products = fetchedProducts;
        isLoading = false;
        filteredProducts = fetchedProducts;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackbar("Error fetching products: $e");
    }
  }

  Future<void> fetchCustomers() async {
    try {
      final fetchedCustomers = await ApiGetCustomer.getAllCustomers();
      setState(() {
        customers = fetchedCustomers;
        selectedCustomer = customers.isNotEmpty ? customers[0].custname : null;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackbar("Failed to fetch customers");
    }
  }

  String getproductimage(String productname) {
    switch (productname) {
      case 'Foundation':
        return "https://i.pinimg.com/736x/e8/6f/d7/e86fd7d5c89b72ada65192e3b19b6bae.jpg";
      case 'Face Wash':
        return "https://i.pinimg.com/736x/2b/e4/8e/2be48eaf93a5204ac91551f758cb19c2.jpg";
      case 'ceram':
        return "https://i.pinimg.com/736x/d1/24/34/d12434894970ae775c331b99fdfd5309.jpg";
      case 'Eye Liner':
        return "https://i.pinimg.com/736x/04/53/7e/04537e83ae95a7cab7a39942d4a9d6e2.jpg";
      case 'Primer':
        return "https://i.pinimg.com/736x/80/aa/23/80aa232c633f64da830663e5db4a89b4.jpg";
      default:
        return "";
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products
          .where((product) =>
              (product.productname ?? '').toLowerCase().contains(query))
          .toList();
    });
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      productQuantities[index] = quantity;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showOrderSummary() {
    final selectedItems = selectedProducts.map((index) {
      final product = products[index];
      final quantity = productQuantities[index] ?? 0;
      return {
        'prdtname': product.productname ?? 'Unknown',
        'quantity': quantity,
        'prdtmrp': product.productMRP ?? 0.0,
        'totalAmount': (product.productMRP ?? 0.0) * quantity,
      };
    }).toList();

    final totalAmount = selectedItems.fold<double>(
      0.0,
      (sum, item) => sum + (item['totalAmount'] as double),
    );

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Order Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Table(
                border: TableBorder.all(),
                children: [
                  const TableRow(
                    decoration: BoxDecoration(color: Colors.purpleAccent),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Product Name",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Quantity",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Price",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Total",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  ...selectedItems.map((item) {
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item['prdtname'].toString()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${item['quantity']}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('\$${item['prdtmrp']}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('\$${item['totalAmount']}'),
                        ),
                      ],
                    );
                  }).toList(),
                  TableRow(
                    decoration: BoxDecoration(color: Colors.purple.shade100),
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Total",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(),
                      const SizedBox(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '\$${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _confirmOrder();
                },
                child: const Text(
                  "Confirm Order",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmOrder() async {
    if (selectedProducts.isEmpty) {
      _showErrorSnackbar("No products selected!");
      return;
    }

    final selectedItems = selectedProducts
        .map((index) {
          final product = products[index];
          final quantity = productQuantities[index] ?? 0;
          if (quantity < 1) {
            _showErrorSnackbar(
                "Quantity must be at least 1 for product: ${product.productname}");
            return null;
          }
          final totalAmount = (product.productMRP ?? 0) * quantity;
          if (totalAmount <= 0) {
            _showErrorSnackbar(
                "Total amount must be greater than zero for product: ${product.productname}");
            return null;
          }
          return {
            'prdtid': product.productid,
            'prdtname': product.productname,
            'prdtmrp': product.productMRP,
            'prdtstock': product.productstock,
            'quantity': quantity,
            'totalAmount': totalAmount,
          };
        })
        .where((item) => item != null)
        .toList();

    if (selectedItems.isEmpty) {
      return;
    }

    final totalAmount = selectedItems.fold<double>(
      0.0,
      (sum, item) => sum + (item?['totalAmount'] as double),
    );

    final selectedCustomerModel = customers.firstWhere(
      (customer) => customer.custname == selectedCustomer,
      orElse: () => CustomerModel(custname: '', custcity: '', custphNumber: ''),
    );

    final orderRequest = {
      'CustomerId': selectedCustomerModel.custId,
      'netAmount': totalAmount.toInt(),
      'datadetails': selectedItems.map((item) {
        return {
          'productId': item?['prdtid'],
          'productName': item?['prdtname'],
          'quantity': item?['quantity'],
          'totalAmount': item?['totalAmount'],
        };
      }).toList(),
    };

    try {
      final response = await http
          .post(
            Uri.parse('http://localhost:5073/api/OrderThTd/CreateOrder'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(orderRequest),
          )
          .timeout(const Duration(seconds: 10));

      final responseBody = response.body;
      debugPrint('Response body: $responseBody');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        setState(() {
          selectedProducts.clear();
          productQuantities.clear();
        });
        // Fetch updated products to reflect new stock levels
        await fetchProducts();
      } else {
        // Attempt to decode the response body for error details
        final result = json.decode(responseBody);
        final errorMessage = result['ErrorMessage'] ?? 'Unknown error occurred';
        _showErrorSnackbar('Error: $errorMessage');
      }
    } on SocketException catch (_) {
      _showErrorSnackbar("Network error. Please check your connection.");
    } on FormatException catch (_) {
      _showErrorSnackbar("Unexpected response format from the server.");
    } catch (e) {
      // Log the error for debugging
      debugPrint("Error placing order: $e");
      _showErrorSnackbar("Failed to place order. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        backgroundColor: Colors.purple,
        centerTitle: true,
        actions: [
          DropdownButton<String>(
            value: customers.isNotEmpty &&
                    customers.any(
                        (customer) => customer.custname == selectedCustomer)
                ? selectedCustomer
                : null,
            dropdownColor: Colors.purple.shade300,
            items: customers.map((customer) {
              return DropdownMenuItem<String>(
                value: customer.custname ?? '',
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text('${customer.custname}'),
                  ],
                ),
              );
            }).toList(),
            onChanged: customers.isEmpty
                ? null
                : (String? newValue) {
                    setState(() {
                      selectedCustomer = newValue!;
                      print('Selected customer: $selectedCustomer');
                    });
                  },
          ),
        ],
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search Products',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 2.7,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          String imageUrl =
                              getproductimage(product.productname ?? '');
                          final stock = product.productstock ?? 0;
                          return Card(
                            color: Colors.purple.shade200,
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: selectedProducts.contains(index),
                                        onChanged: (isSelected) {
                                          setState(() {
                                            if (isSelected!) {
                                              selectedProducts.add(index);
                                            } else {
                                              selectedProducts.remove(index);
                                            }
                                          });
                                        },
                                      ),
                                      Expanded(
                                          child:
                                              Text(product.productname ?? '')),
                                      Column(
                                        children: [
                                          Image.network(
                                            imageUrl,
                                            height: 70,
                                            width: 200,
                                            fit: BoxFit.fill,
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  Text("Price: \$${product.productMRP ?? 0.0}"),
                                  Text(
                                    stock > 0
                                        ? "Stock: $stock"
                                        : "Out of Stock",
                                    style: TextStyle(
                                      color:
                                          stock > 0 ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          if ((productQuantities[index] ?? 0) >
                                              0) {
                                            _updateQuantity(
                                                index,
                                                (productQuantities[index] ??
                                                        0) -
                                                    1);
                                          } else {
                                            _showErrorSnackbar(
                                                "Cannot reduce below 0!");
                                          }
                                        },
                                      ),
                                      Text('${productQuantities[index] ?? 0}'),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          if ((productQuantities[index] ?? 0) <
                                              stock) {
                                            _updateQuantity(
                                                index,
                                                (productQuantities[index] ??
                                                        0) +
                                                    1);
                                          } else {
                                            _showErrorSnackbar(
                                                "Cannot add more than available stock!");
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _showOrderSummary,
                      child: const Text(
                        "Place Order",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        minimumSize: Size(80, 80),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
