import 'package:billingapp/const.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCustomerPage extends StatefulWidget {
  @override
  _AddCustomerPageState createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();

    if (name.isEmpty || mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter name and mobile number.')),
      );
      return;
    }

    final customer = {'name': name, 'mobile': mobile};

    try {
      await FirebaseFirestore.instance.collection('customers').add(customer);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Customer added successfully.')),
      );

      _nameController.clear();
      _mobileController.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add customer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Color.fromARGB(255, 100, 143, 138))),
        onPressed: () {
          _showAddCustomerDialog();
        },
        child: Text('Add Customer', style: TextStyle(fontFamily: 'Poppins')),
      ),
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Add Customer', style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            Text('Added Customers',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            SizedBox(height: 8.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('customers')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final customers = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customerData =
                            customers[index].data() as Map<String, dynamic>;
                        final customerName = customerData['name'];
                        return Column(
                          children: [
                            Container(
                              child: ListTile(
                                title: Text(customerName,
                                    style: TextStyle(fontFamily: 'Poppins')),
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
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Failed to retrieve customers',
                        style: TextStyle(fontFamily: 'Poppins'));
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddCustomerDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Customer',
              style: TextStyle(
                fontFamily: 'Poppins',
              )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
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
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 100, 143, 138))),
              onPressed: () {
                _saveCustomer();
                Navigator.of(context).pop();
              },
              child: Text('Save', style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }
}
