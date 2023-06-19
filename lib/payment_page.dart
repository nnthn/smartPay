import 'package:billingapp/const.dart';
import 'package:billingapp/homepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPage extends StatelessWidget {
  final String customerName;
  final String mobileNumber;
  final List<Map<String, dynamic>> soldItems;

  PaymentPage({
    required this.customerName,
    required this.mobileNumber,
    required this.soldItems,
  });

  void _updateSalesHistory(String paymentOption) {
    // Create a new document in the sales history collection
    FirebaseFirestore.instance.collection('sales_history').add({
      'customerName': customerName,
      'mobileNumber': mobileNumber,
      'soldItems': soldItems,
      'paymentOption': paymentOption,
      'date': DateTime.now(),
    });

    // Update product quantities in the database
    soldItems.forEach((item) {
      final productName = item['productName'];
      final quantity = item['quantity'];

      FirebaseFirestore.instance
          .collection('products')
          .where('productName', isEqualTo: productName)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          final currentQuantity = doc.data()['quantity'] ?? 0;
          final updatedQuantity = currentQuantity - quantity;

          FirebaseFirestore.instance
              .collection('products')
              .doc(doc.id)
              .update({'quantity': updatedQuantity});
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: $customerName',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            SizedBox(height: 8.0),
            Text('Mobile Number: $mobileNumber',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
            SizedBox(height: 16.0),
            Text('Selected Items:',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 14)),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: soldItems.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = soldItems[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(item['productName'],
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        subtitle: Text(
                            'Quantity: ${item['quantity']?.toString() ?? "N/A"}',
                            style: TextStyle(fontFamily: 'Poppins')),
                        trailing: Text(
                            'Price: ${item['price']?.toString() ?? "N/A"}',
                            style: TextStyle(fontFamily: 'Poppins')),
                      ),
                      CustomDivider(
                          height: 1.0,
                          thickness: 1.0,
                          color: Colors.grey,
                          dashWidth: 5.0,
                          dashGap: 3.0),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Text('Select Payment Option',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _updateSalesHistory('Pay Later');
                        // Perform any additional logic for "Pay Later" payment option

                        Navigator.push(
                          context as BuildContext,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      },
                      child: Text('Pay Later',
                          style: TextStyle(fontFamily: 'Poppins')),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _updateSalesHistory('Instant Pay');
                        // Perform any additional logic for "Instant Pay" payment option

                        Navigator.push(
                          context as BuildContext,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      },
                      child: Text('Instant Pay',
                          style: TextStyle(fontFamily: 'Poppins')),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
