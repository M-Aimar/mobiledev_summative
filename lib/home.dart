import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rushgrocery/cart.dart';
import 'package:rushgrocery/orders.dart';
import 'browse.dart';
import 'category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _searchText = '';

  void _performSearch(String value) {
    setState(() {
      _searchText = value;
    });
  }

  final List<Widget> pages = [
    const HomeScreen(),
    const BrowseItemsPage(),
    const OrdersPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
          title: const Text(
            'Groceries',
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
              preferredSize: const Size.fromHeight(60),
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
                              onChanged: _performSearch),
                        ),
                      ]),
                    )),
              ))),
      backgroundColor: Colors.white,
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.height * 0.5,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 10,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CategoryPage(categoryId: 'pastry'),
                          ));
                    },
                    child: Stack(children: [
                      Image.asset(
                        "assets/images/Rectangle 29.png",
                      ),
                      const Positioned(
                        left: 10,
                        top: 10,
                        child: Text("Pastry",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      )
                    ]),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CategoryPage(categoryId: 'vegetables'),
                          ));
                    },
                    child: Stack(children: [
                      Image.asset(
                        "assets/images/Rectangle 30.png",
                      ),
                      const Positioned(
                        left: 10,
                        top: 10,
                        child: Text("Vegetables",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      )
                    ]),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CategoryPage(categoryId: 'eggs&dairy'),
                          ));
                    },
                    child: Stack(children: [
                      Image.asset(
                        "assets/images/Rectangle 31.png",
                      ),
                      const Positioned(
                        left: 10,
                        top: 10,
                        child: Text("Eggs & Dairy",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      )
                    ]),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CategoryPage(categoryId: 'fruit'),
                            ));
                      },
                      child: Stack(children: [
                        Image.asset("assets/images/Rectangle 29.png",
                            fit: BoxFit.fill),
                        const Positioned(
                          left: 10,
                          top: 10,
                          child: Text("Fruit",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        )
                      ])),
                ],
              ),
            )
          ])),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          // Navigates to the corresponding page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pages[index]),
          );
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.search), label: "Browse"),
          const BottomNavigationBarItem(
              icon: const Icon(Icons.book), label: "Order History"),
          const BottomNavigationBarItem(
              icon: const Icon(Icons.person), label: "Profile"),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(color: Colors.green),
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
