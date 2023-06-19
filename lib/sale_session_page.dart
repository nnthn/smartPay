import 'package:billingapp/const.dart';
import 'package:billingapp/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SaleSessionPage extends StatefulWidget {
  @override
  _SaleSessionPageState createState() => _SaleSessionPageState();
}

class _SaleSessionPageState extends State<SaleSessionPage> {
  String _selectedCustomer = '';
  String _selectedMobileNo = '';
  List<Map<String, dynamic>> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Color.fromARGB(255, 100, 143, 138))),
        onPressed: () async {
          // Display the backdrop and select customer dropdown
          final selectedCustomer =
              await showModalBottomSheet<Map<String, dynamic>>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Customer',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 8.0),
                    FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .collection('customers')
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (snapshot.hasError) {
                          return Text('Error fetching customers.');
                        }

                        final customers = snapshot.data!.docs;

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: customers.length,
                          itemBuilder: (context, index) {
                            final customerData = customers[index].data();
                            final customerName = customerData['name'] ?? '';
                            final mobileNo = customerData['mobile'] ?? '';

                            return Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    customerName,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  subtitle: Text(
                                    mobileNo,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(
                                      context,
                                      {
                                        'customerName': customerName,
                                        'mobileNo': mobileNo,
                                      },
                                    );
                                  },
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
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );

          if (selectedCustomer != null) {
            setState(() {
              _selectedCustomer = selectedCustomer['customerName'];
              _selectedMobileNo = selectedCustomer['mobileNo'];
            });
          }
        },
        child: Text(
          'Select Customer',
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Sale Session',
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            if (_selectedCustomer.isNotEmpty) ...[
              Text(
                'Selected Customer: $_selectedCustomer',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Mobile No: $_selectedMobileNo',
                style: TextStyle(
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Add Items to Sale',
                style: TextStyle(
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Navigate to the page where you can select items from the inventory
                      final selectedItem =
                          await showModalBottomSheet<Map<String, dynamic>>(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Items',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                FutureBuilder<
                                    QuerySnapshot<Map<String, dynamic>>>(
                                  future: FirebaseFirestore.instance
                                      .collection('products')
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }

                                    if (snapshot.hasError) {
                                      return Text('Error fetching inventory.');
                                    }
                                    final inventory = snapshot.data!.docs;

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: inventory.length,
                                      itemBuilder: (context, index) {
                                        final documentSnapshot =
                                            inventory[index];
                                        final data = documentSnapshot.data();

                                        final productName =
                                            data['productName'] ?? '';
                                        final price = data['price'] ?? '';
                                        var quantity = data['quantity'] ?? 0;
                                        final initialQuantity =
                                            data['quantity'] ??
                                                0; // Retrieve initial quantity

                                        return Column(
                                          children: [
                                            ListTile(
                                              title: Text(
                                                productName,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                              subtitle: Text(
                                                'Price: $price & Quantity: $quantity',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                              onTap: () {
                                                if (quantity == 0) {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Product Out of Stock'),
                                                        content: Text(
                                                            'This product is currently out of stock. Please restock.'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text('OK'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  Navigator.pop(context, data);
                                                }
                                              },
                                              tileColor: quantity == 0
                                                  ? Colors.grey.withOpacity(0.5)
                                                  : null,
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
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );

                      if (selectedItem != null) {
                        setState(() {
                          final int initialQuantity =
                              selectedItem['quantity'] ??
                                  0; // Retrieve initial quantity
                          selectedItem['initialQuantity'] =
                              initialQuantity; // Add initial quantity to the selected item
                          _selectedItems.add(selectedItem);
                        });
                      }
                    },
                    child: Text(
                      'Add Items',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Sale Details',
                style: TextStyle(
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 8.0),
              if (_selectedItems.isEmpty)
                Text(
                  'No items added to sale.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                  ),
                )
              else
                Column(
                  children: _selectedItems.map((item) {
                    final productName = item['productName'] ?? '';
                    final price = item['price'] ?? '';
                    var quantity = item['quantity'] ?? 0;
                    final initialQuantity = item['initialQuantity'] ??
                        0; // Retrieve initial quantity

                    return Column(
                      children: [
                        Container(
                          child: ListTile(
                            title: Text(
                              productName,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                              ),
                            ),
                            subtitle: Text(
                              'Price: $price & Quantity: $quantity',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  if (quantity < initialQuantity) {
                                    // Check if the quantity is less than the initial quantity
                                    quantity++;
                                    item['quantity'] = quantity;
                                  }
                                });
                              },
                            ),
                            leading: IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (quantity > 0) {
                                    quantity--;
                                    item['quantity'] = quantity;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        CustomDivider(
                            height: 1.0,
                            thickness: 1.0,
                            color: Colors.grey,
                            dashWidth: 5.0,
                            dashGap: 3.0),
                      ],
                    );
                  }).toList(),
                ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: _selectedItems.isNotEmpty
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentPage(
                                  customerName: _selectedCustomer,
                                  mobileNumber: _selectedMobileNo,
                                  soldItems: _selectedItems,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      'Proceed to Payment',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
