import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return ListTile(
                title: Text(data['productName']),
                subtitle: Text('Quantity: ${data['qty']}'),
                trailing: Text('Price: \$${data['price']}'),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add-product');
            },
          ),
          SizedBox(height: 16.0),
          FloatingActionButton(
            child: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/sell-product');
            },
          ),
          SizedBox(height: 16.0),
          FloatingActionButton(
            child: Icon(Icons.list),
            onPressed: () {
              Navigator.pushNamed(context, '/billing');
            },
          ),
        ],
      ),
    );
  }
}
