import 'package:fcustomerdetails/home/home_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures Flutter binding is initialized
  // Perform any necessary asynchronous initialization here
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopMart',
      theme: ThemeData(
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(),
      ),
      home: const MyHomePage(
        title: 'ShopMart',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
