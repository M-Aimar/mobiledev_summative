import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart.dart';

// Get the current user ID
String getCurrentUserId() {
  User? user = FirebaseAuth.instance.currentUser;
  String userId = user!.uid;
  return userId;
}

class ProductPage extends StatefulWidget {
  final String productName;
  final int price;
  final String imageURL;
  final int quantity;

  const ProductPage({
    Key? key,
    required this.productName,
    required this.price,
    required this.imageURL,
    required this.quantity,
  }) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final String userId = getCurrentUserId();

  CollectionReference cartItemsCollection =
      FirebaseFirestore.instance.collection('cartItems');

  void addProductToCart(String userId, String productName, int productPrice,
      String imageURL, int quantity) {
    CollectionReference cartItemsCollection =
        FirebaseFirestore.instance.collection('cart');
    cartItemsCollection.add({
      'userId': getCurrentUserId(),
      'name': productName,
      'price': widget.price,
      'image': imageURL,
      'quantity': 1
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.30,
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
              child: const IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: null,
              ),
            ),
          ],
          flexibleSpace: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.imageURL,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.productName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xff666565)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                'Rwf ${widget.price}',
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.green),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Price Type',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Category',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Vendors',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
                width: MediaQuery.of(context).size.width * 0.80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    primary: Colors.white,
                  ),
                  child: const Text(
                    "Add To Cart",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () {
                    Map<String, dynamic> product = {
                      "name": widget.productName,
                      "price": widget.price,
                      "quantity": 1,
                      "imageURL": widget.imageURL,
                    };

                    // Call the addToCart method of the CartPage
                    addProductToCart(userId, widget.productName, widget.price,
                        widget.imageURL, widget.quantity);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
