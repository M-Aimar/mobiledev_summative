import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rushgrocery/payment_page.dart';
import 'address.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'address_util.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String deliveryAddress = 'Address: ""';
  CollectionReference cartItemsCollection =
      FirebaseFirestore.instance.collection('cart');

  List<Map<String, dynamic>> items = [];

  void updateCartItem(String userId, Map<String, dynamic> updatedData) {
    cartItemsCollection
        .doc(userId)
        .update(updatedData)
        .then((value) => print("Item updated successfully"))
        .catchError((error) => print("Failed to update item: $error"));
  }

  Future<void> _navigateToEditAddressPage() async {
    final updatedAddress = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditAddressPage(
                currentAddress:
                    deliveryAddress, // Pass the current address as an argument
              )),
    );

    // Handle the updated address returned from EditAddressPage
    if (updatedAddress != null) {
      setState(() {
        deliveryAddress = updatedAddress;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    String userId = getCurrentUserId(); // Get the current user ID

    QuerySnapshot querySnapshot = await cartItemsCollection
        .where('userId', isEqualTo: userId)
        .get(); // Retrieve cart items for the current user

    setState(() {
      items = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  String getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;
    return userId;
  }

  @override
  Widget build(BuildContext context) {
    double deliveryAmount = 1000;
    double totalPrice =
        items.fold(0, (sum, item) => sum + item["price"] * item["quantity"]);
    double total = totalPrice + deliveryAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                _navigateToEditAddressPage();
              },
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: InkWell(
                      onTap: () {
                        _navigateToEditAddressPage();
                      },
                      child: Text(
                        deliveryAddress,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff7a7979),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          primary: Colors.white,
                        ),
                        child: const Text(
                          "Change",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 15,
                          ),
                        ),
                        onPressed: () {
                          _navigateToEditAddressPage();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.30,
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: Image.network(
                          items[index]["image"],
                          fit: BoxFit.fill,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[index]["name"].length > 7
                                ? items[index]["name"].substring(0, 7) +
                                    "..." // Limit to 15 characters with ellipsis
                                : items[index]["name"],
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            "\Rwf ${items[index]["price"]}",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (items[index]["quantity"] > 1) {
                                  items[index]["quantity"]--;
                                  updateCartItem(items[index]["userId"],
                                      {"quantity": items[index]["quantity"]});
                                }
                              });
                            },
                            icon: Icon(Icons.remove),
                          ),
                          Text("${items[index]["quantity"]}"),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                items[index]["quantity"]++;
                                updateCartItem(items[index]["userId"],
                                    {"quantity": items[index]["quantity"]});
                              });
                            },
                            icon: Icon(Icons.add),
                          ),
                          IconButton(
                            onPressed: () {
                              cartItemsCollection
                                  .doc(items[index]["userId"])
                                  .delete();
                              setState(() {
                                items.removeAt(index);
                              });
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Price Details",
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(height: 8.0),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${items[index]["name"]} x ${items[index]["quantity"]}",
                          ),
                          Text(
                            "\Rwf ${items[index]["price"] * items[index]["quantity"]}",
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Delivery Amount"),
                      Text("\Rwf $deliveryAmount"),
                    ],
                  ),
                ),
                Divider(),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "\Rwf ${total.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
                        child: Text(
                          "Continue To Payment",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 15,
                          ),
                        ),
                        onPressed: () {
                          saveAddressDetails();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(amount: total),
                            ),
                          );
                        }),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
