import 'package:fcustomerdetails/screen/add_customer_screen.dart';
import 'package:fcustomerdetails/screen/add_product_screen.dart';
import 'package:fcustomerdetails/screen/order_screen.dart';
import 'package:fcustomerdetails/screen/update_delete_customer.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
            child: Image.network(
          'https://i.pinimg.com/736x/68/93/f8/6893f869277caf23897de53669382066.jpg',
          fit: BoxFit.cover,
        )),
        // Main content
        Scaffold(
          backgroundColor: Colors.transparent, // Makes Scaffold transparent
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(
              widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 4,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Row 1: Customer Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildOptionCard(
                      icon: Icons.person,
                      title: "Customer Details",
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AddCustomerScreen()));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Row 2: Product Details & Order List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOptionCard(
                      icon: Icons.inventory_2,
                      title: "Product Details",
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AddProductScreen()));
                      },
                    ),
                    _buildOptionCard(
                      icon: Icons.list_alt,
                      title: "Order List",
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductListScreen()));
                        // Add functionality for Order List here
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Row 3: Back Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildOptionCard(
                      icon: Icons.update_rounded,
                      title: "Update Customer",
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CustomerListScreen()));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget to create a professional-looking card with an icon and text.
Widget _buildOptionCard({
  required IconData icon,
  required String title,
  required VoidCallback onPressed,
}) {
  return Card(
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.purpleAccent.shade100, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
