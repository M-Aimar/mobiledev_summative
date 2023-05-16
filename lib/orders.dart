import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String getCurrentUserId() {
      User? user = FirebaseAuth.instance.currentUser;
      String userId = user!.uid;
      return userId;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: getCurrentUserId())
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Widget> orderWidgets = [];

          snapshot.data!.docs.forEach((orderDoc) {
            Map<String, dynamic>? orderData =
                orderDoc.data() as Map<String, dynamic>?;

            if (orderData != null) {
              List<Map<String, dynamic>> orderItems =
                  List<Map<String, dynamic>>.from(orderData['orderItems']);
              String reference = orderData['reference'] ?? '';
              String status = orderData['status'] ?? '';

              List<Widget> itemWidgets = orderItems.map((item) {
                String name = item['name'] ?? '';
                int price = item['price'] ?? 0.0;
                int quantity = item['quantity'] ?? 0;
                return Text(
                  '$name - Quantity: $quantity, Price: $price',
                  style: TextStyle(fontSize: 16.0),
                );
              }).toList();

              Widget orderWidget = Container(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(0, 2),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: itemWidgets,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Reference: $reference',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      'Status: $status',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              );

              orderWidgets.add(orderWidget);
            }
          });

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: orderWidgets,
          );
        },
      ),
    );
  }
}
