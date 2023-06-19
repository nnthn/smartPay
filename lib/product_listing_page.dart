import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductListingPage extends StatelessWidget {
  final primaryColor = Color.fromARGB(255, 100, 143, 138);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching products.'),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No products available.'),
            );
          }

          return Container(
            child: ListView(
              shrinkWrap: true,
              children: snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                final productName = data['productName'] ?? '';
                final price = data['price'] ?? '';
                final quantity = data['quantity'] ?? '';

                return Column(
                  children: [
                    Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border(
                              left: BorderSide(
                                color: primaryColor,
                                width: 16.0,
                              ),
                            ),
                          ),
                          child: ListTile(
                            title: Text(productName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  fontFamily: 'Poppins',
                                )),
                            subtitle: Text('Quantity:' + quantity.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.0,
                                  fontFamily: 'Poppins',
                                )),
                            trailing: Text('Price:' + price.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.0,
                                  fontFamily: 'Poppins',
                                )),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
