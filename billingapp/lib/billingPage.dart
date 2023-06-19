import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillingPage extends StatefulWidget {
  @override
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final CollectionReference billingCollection =
      FirebaseFirestore.instance.collection('billing');
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');
  final TextEditingController valueController = TextEditingController();

  @override
  void dispose() {
    valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Billing'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: billingCollection
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final billingEntries = snapshot.data!.docs;

          if (billingEntries.isEmpty) {
            return Center(child: Text('No billing entries found.'));
          }

          return ListView.builder(
            itemCount: billingEntries.length,
            itemBuilder: (BuildContext context, int index) {
              final billingEntry = billingEntries[index];
              final data = billingEntry.data() as Map<String, dynamic>;
              final productName = data['productName'];
              final quantity = data['quantity'];
              final price = data['price'];
              final totalAmount = data['totalAmount'];
              final timestamp = data['timestamp'];

              return ListTile(
                title: Text(productName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity: $quantity'),
                    Text('Price: \$$price'),
                    Text('Total Amount: \$$totalAmount'),
                  ],
                ),
                trailing: Text(timestamp.toString()),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.create),
        onPressed: () async {
          int? soldQuantity = await showDialog<int>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Enter Sold Quantity'),
                content: TextField(
                  keyboardType: TextInputType.number,
                  controller: valueController,
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
                    child: Text('OK'),
                    onPressed: () {
                      int quantity = int.tryParse(valueController.text) ?? 0;
                      Navigator.of(context).pop(quantity);
                    },
                  ),
                ],
              );
            },
          );
          if (soldQuantity != null && soldQuantity > 0) {
            await generateBillingEntries(soldQuantity);
          }
        },
      ),
    );
  }

  Future<void> generateBillingEntries(int soldQuantity) async {
    QuerySnapshot productsSnapshot = await productsCollection.get();
    List<QueryDocumentSnapshot> products = productsSnapshot.docs;

    // Iterate through the products and create billing entries
    for (var product in products) {
      int availableQuantity = product['qty'];
      int remainingQuantity = availableQuantity - soldQuantity;

      if (remainingQuantity >= 0) {
        int price = product['price'];
        int totalAmount = price * soldQuantity;

        // Create billing entry in Firestore
        await billingCollection.add({
          'productName': product['productName'],
          'quantity': soldQuantity,
          'price': price,
          'totalAmount': totalAmount,
          'timestamp': Timestamp.now(),
        });

        // Update available quantity in products collection
        await productsCollection
            .doc(product.id)
            .update({'qty': remainingQuantity});
      }
    }
  }
}
