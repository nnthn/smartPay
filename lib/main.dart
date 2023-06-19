import 'package:billingapp/generate_bill_page.dart';
import 'package:billingapp/homepage.dart';
import 'package:billingapp/inventory_page.dart';
import 'package:billingapp/payment_page.dart';
import 'package:billingapp/product_listing_page.dart';
import 'package:billingapp/sale_session_page.dart';
import 'package:billingapp/sales_history_page.dart';
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
    final textTheme = Theme.of(context).textTheme.apply(
          fontFamily: 'Poppins',
        );
    const primaryColor = Color.fromARGB(240, 240, 240, 240);
    final primarySwatch = MaterialColor(
      primaryColor.value,
      const <int, Color>{
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
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: primaryColor,
        primarySwatch: primarySwatch,
      ),
      routes: {},
      home: HomePage(),
    );
  }
}
