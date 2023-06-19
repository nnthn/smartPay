import 'dart:io';
import 'package:billingapp/const.dart';
import 'package:billingapp/homepage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GenerateBillPage extends StatelessWidget {
  final String customerName;
  final String mobileNumber;
  final DateTime saleDate;
  final List<Map<String, dynamic>> soldItems;
  final String companyName = 'ABC Company';
  final String companyAddress = '123 Main Street, City, State, Country';

  GenerateBillPage({
    required this.customerName,
    required this.mobileNumber,
    required this.saleDate,
    required this.soldItems,
  });

  String calculateTotalAmount() {
    double totalAmount = 0.0;
    for (var item in soldItems) {
      final price = item['price'] ?? 0.0;
      final quantity = item['quantity'] ?? 0;

      totalAmount += (price * quantity);
    }
    return totalAmount.toStringAsFixed(2);
  }

  String convertToWords(double amount) {
    final units = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine'
    ];
    final tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];
    final teens = [
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];

    if (amount == 0) {
      return 'Zero';
    }

    String amountString = '';
    if (amount >= 10000000) {
      int crore = (amount / 10000000).floor();
      amountString += '${convertToWords(crore.toDouble())} Crore ';
      amount -= crore * 10000000;
    }

    if (amount >= 100000) {
      int lakh = (amount / 100000).floor();
      amountString += '${convertToWords(lakh.toDouble())} Lakh ';
      amount -= lakh * 100000;
    }

    if (amount >= 1000) {
      int thousand = (amount / 1000).floor();
      amountString += '${convertToWords(thousand.toDouble())} Thousand ';
      amount -= thousand * 1000;
    }

    if (amount >= 100) {
      int hundred = (amount / 100).floor();
      amountString += '${convertToWords(hundred.toDouble())} Hundred ';
      amount -= hundred * 100;
    }

    if (amount >= 20) {
      int ten = (amount / 10).floor();
      amountString += '${tens[ten]} ';
      amount -= ten * 10;
    } else if (amount >= 10) {
      int teen = amount.toInt() - 10;
      amountString += '${teens[teen]} ';
      amount = 0;
    }

    if (amount > 0) {
      int unit = amount.toInt();
      amountString += '${units[unit]} ';
    }

    return amountString.trim();
  }

  Future<void> _sharePDF() async {
    final pdf = pw.Document();

    // Add the content to the PDF document
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 2.0, color: PdfColors.black),
            ),
            padding: pw.EdgeInsets.all(16.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    companyName,
                    style: pw.TextStyle(
                      fontSize: 24.0,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    companyAddress,
                    style: pw.TextStyle(fontSize: 12.0),
                  ),
                ),
                pw.SizedBox(height: 24.0),
                pw.Center(
                  child: pw.Text(
                    'Customer: $customerName',
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Mobile Number: $mobileNumber',
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 16.0),
                pw.Center(
                  child: pw.Text(
                    'Date: ${DateFormat('d MMMM yyyy').format(saleDate)}',
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 16.0),
                pw.Center(
                  child: pw.Text(
                    'Sales Information',
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 8.0),
                pw.Table.fromTextArray(
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headers: [
                    'Sl. No.',
                    'Particulars',
                    'Rate',
                    'Quantity',
                    'Amount'
                  ],
                  data: List<List<String>>.generate(
                    soldItems.length,
                    (rowIndex) => [
                      (rowIndex + 1).toString(),
                      soldItems[rowIndex]['productName'] ?? '',
                      soldItems[rowIndex]['price'].toString() ?? '',
                      soldItems[rowIndex]['quantity'].toString() ?? '',
                      (soldItems[rowIndex]['price'] *
                              soldItems[rowIndex]['quantity'])
                          .toString(),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16.0),
                pw.Text('Bill Total: Rs.${calculateTotalAmount()} /-'),
                pw.Text(
                  "Rupees " +
                      convertToWords(double.parse(calculateTotalAmount())) +
                      " only",
                  style: pw.TextStyle(fontSize: 12.0),
                ),
                pw.SizedBox(height: 16.0),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('Signature: ______________________'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save the PDF to a temporary file
    final output = await getTemporaryDirectory();
    final outputFile = File(
        '${output.path}/${customerName}-${DateFormat('d MMMM yyyy').format(saleDate)}-bill.pdf');
    await outputFile.writeAsBytes(await pdf.save());

    // Share the PDF via WhatsApp
    Share.shareFiles(
      [outputFile.path],
      text: 'Dear Customer, the bill of your purchase is attached.',
      subject: 'Bill',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.close),
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        },
      ),
      appBar: AppBar(
        title: Text('Generate Bill'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: $customerName'),
            SizedBox(height: 8.0),
            Text('Mobile Number: $mobileNumber'),
            SizedBox(height: 16.0),
            Text('Date: ${DateFormat('d MMMM yyyy').format(saleDate)}'),
            SizedBox(height: 16.0),
            Text('Sales Information'),
            SizedBox(height: 8.0),
            Column(
              children: soldItems.map<Widget>((item) {
                final productName = item['productName'] ?? '';
                final price = item['price'] ?? '';
                final quantity = item['quantity'] ?? '';

                return Column(
                  children: [
                    Container(
                      child: ListTile(
                        title: Text(productName),
                        subtitle: Text('Price: $price | Quantity: $quantity'),
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
            SizedBox(height: 16.0),
            Text('Bill Total: Rs.${calculateTotalAmount()}'),
            SizedBox(height: 8.0),
            Text(
              convertToWords(double.parse(calculateTotalAmount())) + " only",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _sharePDF();
                  },
                  icon: Icon(Icons.share),
                  label: Text('Generate Bill and Share'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
