import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title:
            Text('Product Management', style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}',
                        style: TextStyle(fontFamily: 'Poppins'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final productData =
                          products[index].data() as Map<String, dynamic>;
                      final String productId = products[index].id;
                      final String productName = productData['productName'];
                      final double price = productData['price'];
                      final int quantity = productData['quantity'];

                      return Column(
                        children: [
                          Material(
                            color: Colors.grey[100],
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ListTile(
                                  title: Text(
                                    productName,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight
                                          .bold, // Making the title font size bold
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Price: Rs ${price.toStringAsFixed(2)}, Quantity: $quantity',
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          // Delete the product from Firestore
                                          FirebaseFirestore.instance
                                              .collection('products')
                                              .doc(productId)
                                              .delete();
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          _showEditDialog(productId,
                                              productName, quantity.toString());
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromRGBO(175, 82, 115, 1))),
                onPressed: () {
                  _showEditDialog('', '', '');
                },
                child: Text('Add Product',
                    style: TextStyle(fontFamily: 'Poppins')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(String productId, String productName, String quantity) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(productId.isEmpty ? 'Add Product' : 'Edit Product',
              style: TextStyle(fontFamily: 'Poppins')),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (productId.isEmpty) ...[
                  TextFormField(
                    controller: _productNameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      labelStyle: TextStyle(fontFamily: 'Poppins'),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a product name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      labelStyle: TextStyle(fontFamily: 'Poppins'),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the price';
                      }
                      // Validate if the input is a valid double
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                ],
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    labelStyle: TextStyle(fontFamily: 'Poppins'),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the quantity';
                    }
                    // Validate if the input is a valid integer
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Color.fromRGBO(175, 82, 115, 1))),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final String productName = _productNameController.text.trim();
                  final int quantity = int.parse(_quantityController.text);

                  if (productId.isEmpty) {
                    // Adding a new product
                    final double price = double.parse(_priceController.text);

                    // Save the product to Firestore
                    FirebaseFirestore.instance.collection('products').add({
                      'productName': productName,
                      'price': price,
                      'quantity': quantity,
                    });
                  } else {
                    // Updating existing product's quantity
                    FirebaseFirestore.instance
                        .collection('products')
                        .doc(productId)
                        .update({
                      'quantity': quantity,
                    });
                  }

                  Navigator.of(context).pop();
                }
              },
              child: Text('Save', style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }
}
