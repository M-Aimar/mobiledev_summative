import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';

import 'orders.dart';

class PaymentPage extends StatefulWidget {
  final double amount;

  PaymentPage({required this.amount});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late PaystackPlugin _paystackPlugin;
  String _paymentError = '';
  String _paymentReference = '';

  @override
  void initState() {
    super.initState();
    _paystackPlugin = PaystackPlugin();
    _paystackPlugin.initialize(
        publicKey: 'pk_test_32e455c26f275f469527154d5c71c5f1333bd3cc');
  }

  void _startPayment() async {
    // Get the current user's email
    User? user = FirebaseAuth.instance.currentUser;
    String email = user?.email ?? '';

    // Generate a unique reference ID
    String reference = FirebaseFirestore.instance.collection('orders').doc().id;

    Charge charge = Charge()
      ..amount = (widget.amount * 100).toInt() // Amount in kobo
      ..email = email // Customer's email
      ..reference = reference; // Unique reference for the transaction

    CheckoutResponse response = await _paystackPlugin.checkout(
      context,
      charge: charge,
      fullscreen: false,
      method: CheckoutMethod.card,
    );

    if (response.status == true) {
      // Payment successful
      setState(() {
        _paymentError = '';
        _paymentReference = response.reference!;
      });

      // Remove paid items from the cart collection
      FirebaseFirestore.instance
          .collection("cart")
          .where("userId", isEqualTo: user?.uid)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((documentSnapshot) {
          documentSnapshot.reference.delete();
        });
      }).catchError((error) {
        // Handle any errors that occur during the removal process
        print("Error removing items from cart: $error");
      });

      // Open the orders page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrdersPage()),
      );
    } else {
      // Payment failed
      setState(() {
        _paymentError = 'Payment failed. Please try again.';
        _paymentReference = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Amount: \Rwf${widget.amount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startPayment,
              child: Text('Make Payment'),
            ),
            SizedBox(height: 16),
            Text(
              _paymentError,
              style: TextStyle(color: Colors.red),
            ),
            Text(
              'Payment Reference: $_paymentReference',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
