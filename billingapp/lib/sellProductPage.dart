import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellProductPage extends StatefulWidget {
  @override
  _SellProductPageState createState() => _SellProductPageState();
}

class _SellProductPageState extends State<SellProductPage> {
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');

  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sell Product'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return Center(child: Text('No products available.'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              final product = products[index];
              final data = product.data() as Map<String, dynamic>;
              final productName = data['productName'];
              final quantity = data['qty'];

              return ListTile(
                title: Text(productName),
                subtitle: Text('Quantity: $quantity'),
                trailing: ElevatedButton(
                  onPressed: () {
                    showSellDialog(product.id, productName, quantity);
                  },
                  child: Text('Sell'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void showSellDialog(
      String productId, String productName, int currentQuantity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sell $productName'),
          content: TextField(
            controller: _quantityController,
            decoration: InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              // Handle quantity validation or additional logic if required
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Sell'),
              onPressed: () {
                int quantityToSell = int.parse(_quantityController.text);
                sellProduct(
                    productId, productName, currentQuantity, quantityToSell);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void sellProduct(String productId, String productName, int currentQuantity,
      int quantityToSell) {
    int updatedQuantity = currentQuantity - quantityToSell;
    if (updatedQuantity >= 0) {
      productsCollection.doc(productId).update({'qty': updatedQuantity});
      createBillingEntry(productName, quantityToSell);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Insufficient Quantity'),
            content: Text('Not enough quantity available for sale.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void createBillingEntry(String productName, int quantitySold) {
    FirebaseFirestore.instance.collection('billing').add({
      'productName': productName,
      'quantitySold': quantitySold,
      'timestamp': Timestamp.now(),
    });
  }
}
