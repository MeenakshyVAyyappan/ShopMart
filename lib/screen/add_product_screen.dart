import 'package:flutter/material.dart';
import 'package:shopmart/model/product_model.dart';
import 'package:shopmart/service/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mrpcontroller = TextEditingController();
  final TextEditingController _stockcontroller = TextEditingController();
  bool _isLoading = false;
  Future<void> _submitProduct() async {
    final name = _nameController.text.trim();
    final mrp = _mrpcontroller.text.trim();
    final stock = _stockcontroller.text.trim();

    // Validation to ensure all fields are filled
    if (name.isEmpty || mrp.isEmpty || stock.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Stock validation: ensuring stock is a valid number
    int stockQuantity = int.tryParse(stock) ?? 0;
    if (stockQuantity < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock quantity cannot be negative!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // MRP validation: ensuring MRP is a valid number
    int mrpValue = int.tryParse(mrp) ?? 0;
    if (mrpValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('MRP must be greater than 0!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Start loading indicator while waiting for the API response
    setState(() {
      _isLoading = true;
    });

    // Create the product object
    final newProduct = ProductModel(
      productname: name,
      productMRP: mrpValue,
      productstock: stockQuantity,
    );

    // Call the API to add the product
    final success = await ApiServiceProduct.addProduct(newProduct);

    // Handle success or failure response
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _nameController.clear();
      _mrpcontroller.clear();
      _stockcontroller.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add Product.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Reset the loading state
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape:
            ContinuousRectangleBorder(borderRadius: BorderRadius.circular(700)),
        title: const Text(
          "Add Customer",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Product Name",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mrpcontroller,
              decoration: InputDecoration(
                labelText: "Product MRP",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _stockcontroller,
              decoration: InputDecoration(
                labelText: "Stock",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.production_quantity_limits),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Submit",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
