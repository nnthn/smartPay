import 'package:billingapp/const.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PayLaterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pay Later'),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sales_history')
            .where('paymentOption', isEqualTo: 'Pay Later')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error fetching sales history.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
            );
          }

          final sales = snapshot.data!.docs;

          if (sales.isEmpty) {
            return Center(
              child: Text(
                'No sales marked as Pay Later.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];
              final customerName = sale['customerName'] ?? '';
              final mobileNumber = sale['mobileNumber'] ?? '';
              final soldItems = sale['soldItems'] ?? [];
              final paymentOption = sale['paymentOption'] ?? '';
              final date = sale['date']?.toDate();

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    'Customer: $customerName',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        'Mobile Number: $mobileNumber',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Payment Option: $paymentOption',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Date: ${date.toString()}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Sold Items:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8),
                      Column(
                        children: soldItems.map<Widget>((item) {
                          final productName = item['productName'] ?? '';
                          final price = item['price'] ?? '';
                          final quantity = item['quantity'] ?? '';

                          return Column(
                            children: [
                              Container(
                                child: ListTile(
                                  title: Text(
                                    productName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Price: $price | Quantity: $quantity | Total: ${price * quantity}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                              CustomDivider(
                                height: 1.0,
                                thickness: 1.0,
                                color: Colors.grey,
                                dashWidth: 5.0,
                                dashGap: 3.0,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Update the payment status to "Paid"
                      FirebaseFirestore.instance
                          .collection('sales_history')
                          .doc(sale.id)
                          .update({'paymentOption': 'Paid'});

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sale marked as Paid.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text(
                      'Mark as Paid',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
