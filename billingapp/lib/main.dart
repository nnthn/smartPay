import 'package:billingapp/addProducts.dart';
import 'package:billingapp/billingPage.dart';
import 'package:billingapp/loginpage.dart';
import 'package:billingapp/sellProductPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF183C6F);
    final primarySwatch = MaterialColor(
      primaryColor.value,
      <int, Color>{
        50: primaryColor,
        100: primaryColor,
        200: primaryColor,
        300: primaryColor,
        400: primaryColor,
        500: primaryColor,
        600: primaryColor,
        700: primaryColor,
        800: primaryColor,
        900: primaryColor,
      },
    );

    return MaterialApp(
      routes: {
        '/add-product': (context) => AddProductPage(),
        '/sell-product': (context) => SellProductPage(),
        '/billing': (context) => BillingPage(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: primaryColor,
        primarySwatch: primarySwatch,
      ),
      home: const LoginPage(),
    );
  }
}
