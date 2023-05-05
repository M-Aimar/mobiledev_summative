import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveAddressDetails() async {
  // Retrieve the entered address details

  CollectionReference cartItemsCollection =
      FirebaseFirestore.instance.collection('cart');

  String getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;
    return userId;
  }

  String userId = getCurrentUserId(); // Get the current user ID

  QuerySnapshot querySnapshot = await cartItemsCollection
      .where('userId', isEqualTo: userId)
      .get(); // Retrieve cart items for the current user

  List<Map<String, dynamic>> items = querySnapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();

  List<Map<String, dynamic>> orderItems = items.map((item) {
    return {
      "name": item["name"],
      "price": item["price"],
      "quantity": item["quantity"],
    };
  }).toList();

  String reference = DateTime.now().millisecondsSinceEpoch.toString();

  // Create a new order document
  FirebaseFirestore.instance.collection("orders").add({
    "userId": userId,
    "orderItems": orderItems,
    "status": "awaiting payment",
    "reference": reference,
  }).then((value) {
    // Order successfully created
    // You can perform any additional actions or show a success message
  }).catchError((error) {
    // An error occurred while creating the order
    // Handle the error accordingly (e.g., show an error message)
  });
}
