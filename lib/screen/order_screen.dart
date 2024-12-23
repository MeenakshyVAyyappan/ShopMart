import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fcustomerdetails/model/product_model.dart';
import 'package:fcustomerdetails/service/product_service.dart';
import 'package:fcustomerdetails/service/customer_service.dart';
import 'package:fcustomerdetails/model/customer_model.dart';
import 'package:http/http.dart' as http;

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<ProductModel> products = [];
  List<CustomerModel> customers = [];
  String? selectedCustomer;
  bool isLoading = true;
  Map<int, int> productQuantities = {}; // Quantities for each product
  Set<int> selectedProducts = {}; // Indices of selected products

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _fetchCustomers();
  }

  Future<void> fetchProducts() async {
    try {
      final fetchedProducts = await ApiGetProduct.fetchProducts();
      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching products: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCustomers() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<CustomerModel> fetchedCustomers =
          await ApiGetCustomer.getAllCustomers();
      setState(() {
        customers = fetchedCustomers;
        isLoading = false;
        selectedCustomer = customers.isNotEmpty ? customers[0].custname : null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch customers')),
      );
    }
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      productQuantities[index] = quantity;
    });
  }

  Future<void> _confirmOrder() async {
    final selectedItems = selectedProducts.map((index) {
      final product = products[index];
      final quantity = productQuantities[index] ?? 0; // Default quantity 0
      return {
        'PRDTID': product.productid,
        'PRDTNAME': product.productname,
        'Quantity': quantity,
        'TotalAmount': (product.productMRP ?? 0) * quantity,
      };
    }).toList();

    final totalAmount = selectedItems.fold<double>(
      0.0,
      (sum, item) => sum + (item['TotalAmount'] as double),
    );

    final orderRequest = {
      'CUSTID': 1, // Replace with the actual customer ID
      'NetAmount': totalAmount,
      'OrderDetails': selectedItems,
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5073/api/OrderThTd/CreateOrder'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(orderRequest),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print(result['Message']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );

        // Clear all data after order is placed
        setState(() {
          selectedProducts.clear();
          productQuantities.clear();
        });
      } else {
        final result = json.decode(response.body);
        print('Error: ${result['ErrorMessage']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['ErrorMessage'])),
        );
      }
    } catch (e) {
      print("Error while sending order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order')),
      );
    }
  }

  Future<void> updateStock(int productId, BuildContext context) async {
    try {
      // Find the product in your local list (this should be maintained locally in your app)
      final product = products.firstWhere((p) => p.productid == productId);

      if (product.productstock! > 0) {
        // Decrement stock locally
        setState(() {
          product.productstock = product.productstock! - 1;
        });

        // Prepare the updated product data
        final updatedData = {
          'PRDTID': productId,
          'PRDTNAME': product.productname,
          'PRDTMRP': product.productMRP,
          'PRDTSTOCK': product.productstock,
        };

        // Make the PUT request to update the product on the server
        final response = await http.put(
          Uri.parse('https://localhost:7233/api/Product/$productId'),
          body: json.encode(updatedData),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Stock updated successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to update stock: ${response.statusCode}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product is out of stock.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating stock: $e')),
      );
    }
  }

  void _showOrderSummary() {
    final selectedItems = selectedProducts.map((index) {
      final product = products[index];
      final quantity = productQuantities[index] ?? 0;
      return {
        'name': product.productname,
        'quantity': quantity,
        'amount': (product.productMRP ?? 0) * quantity,
      };
    }).toList();

    final totalAmount = selectedItems.fold<double>(0.0, (sum, item) {
      return sum + (item['amount'] as double? ?? 0.0);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Order Summary",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: Colors.purple.shade200),
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey),
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
                          "Qty",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Amount",
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
                          child: Text(item['name'].toString()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item['quantity'].toString()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "\$${(item['amount'] as double).toStringAsFixed(2)}"),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Total: \$${totalAmount.toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _confirmOrder(); // Call the function to confirm the order
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    child: const Text(
                      "Confirm Your Order",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade300),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSearchPressed() {
    // Implement your search logic here
    showSearch(context: context, delegate: ProductSearchDelegate(products));
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
            value: selectedCustomer,
            hint: const Text(
              "Select Customer",
              style: TextStyle(color: Colors.white),
            ),
            dropdownColor: Colors.purple.shade300,
            icon: const Icon(
              Icons.menu_rounded,
              color: Colors.white,
            ),
            items: customers.map((customer) {
              return DropdownMenuItem<String>(
                value: customer.custname,
                child: Text(customer.custname ?? "UNKNOWN"),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCustomer = value;
              });
            },
          ),
          IconButton(
              onPressed: () {
                _onSearchPressed();
              },
              icon: const Icon(
                Icons.search_off_rounded,
                color: Colors.white,
              ))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
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
                      final stock = products[index].productstock ?? 0;
                      final product = products[index];
                      return Card(
                        color: Colors.purple.shade200,
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Product details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value:
                                              selectedProducts.contains(index),
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
                                          child: Text(product.productname ??
                                              'Unnamed Product'),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "Price: \$${product.productMRP ?? 0.0}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      stock > 0
                                          ? "Stock: $stock"
                                          : "Out of Stock",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: stock > 0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            if (productQuantities[index]! > 0) {
                                              _updateQuantity(
                                                  index,
                                                  productQuantities[index]! -
                                                      1);
                                            }
                                          },
                                        ),
                                        Text(
                                            '${productQuantities[index] ?? 0}'),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            _updateQuantity(
                                                index,
                                                (productQuantities[index] ??
                                                        0) +
                                                    1);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Product Image
                              Image.network(
                                'https://i.pinimg.com/736x/20/f4/c5/20f4c501d07154468a23428fe92f9daf.jpg',
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
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
                    "Show Order Summary",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                  ),
                ),
              ],
            ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate {
  final List<ProductModel> products;

  ProductSearchDelegate(this.products);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear search query
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search delegate
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = products
        .where((product) =>
            product.productname?.toLowerCase().contains(query.toLowerCase()) ??
            false)
        .toList();

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No products found!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          title: Text(product.productname ?? 'Unnamed Product'),
          subtitle: Text('Price: \$${product.productMRP ?? 0.0}'),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = products
        .where((product) =>
            product.productname?.toLowerCase().contains(query.toLowerCase()) ??
            false)
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final product = suggestions[index];
        return ListTile(
          title: Text(product.productname ?? 'Unnamed Product'),
          subtitle: Text('Price: \$${product.productMRP ?? 0.0}'),
        );
      },
    );
  }
}
