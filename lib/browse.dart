import 'package:flutter/material.dart';
import 'package:rushgrocery/cart.dart';
import 'package:rushgrocery/orders.dart';
import 'package:rushgrocery/profile.dart';
import 'browse.dart';
import 'home.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class BrowseItemsPage extends StatefulWidget {
  const BrowseItemsPage({Key? key}) : super(key: key);

  @override
  State<BrowseItemsPage> createState() => _BrowseItemsPageState();
}

class _BrowseItemsPageState extends State<BrowseItemsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Widget> pages = [
    const HomeScreen(),
    const BrowseItemsPage(),
    OrdersPage(),
    ProfilePage()
  ];

  String _searchText = '';

  void _performSearch(String value) {
    setState(() {
      _searchText = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
          title: const Text(
            'Browse',
            style: TextStyle(),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
              child: const IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: null,
              ),
            ),
          ],
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                    width: 330,
                    child: BottomAppBar(
                      shape: const CircularNotchedRectangle(),
                      child: Row(children: [
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            // Open drawer
                          },
                        ),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search Product',
                              border: InputBorder.none,
                            ),
                            onChanged: _performSearch,
                          ),
                        ),
                      ]),
                    )),
              ))),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final products = snapshot.data!.docs;
            List<QueryDocumentSnapshot> filteredProducts = products
                .where((category) => category['name']
                    .toString()
                    .toLowerCase()
                    .contains(_searchText.toLowerCase()))
                .toList();

            return GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (BuildContext context, int index) {
                final product = filteredProducts[index];

                return GestureDetector(
                  onTap: () {
                    // Navigate to category page using category id
                    Navigator.pushNamed(context, '/product',
                        arguments: product.id);
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                product['imageURL'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rwf ${product['price']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Text('No products found.');
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          // Navigates to the corresponding page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pages[index]),
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Browse",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Order History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(color: Colors.green),
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
