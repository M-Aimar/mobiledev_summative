import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';
import 'auth_screen.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Rush Groceries",
      theme: ThemeData(primarySwatch: Colors.green),
      home: const Splash(),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        '/splash': (context) => const Splash(),
      },
      initialRoute: '/splash',
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Create the animation controller and animation objects
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start the animation and navigate to the next screen after 3 seconds
    _animationController.forward();
    Timer(const Duration(seconds: 3),
        () => Navigator.pushNamed(context, '/auth'));
  }

  @override
  void dispose() {
    // Dispose of the animation controller when the widget is removed from the widget tree
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a Stack to position the logo on top of the background image
      body: Stack(
        children: [
          // Background image
          ColorFiltered(
            colorFilter: const ui.ColorFilter.matrix([
              0.7, 0, 0, 0, 0, // red
              0, 0.7, 0, 0, 0, // green
              0, 0, 0.7, 0, 0, // blue
              0, 0, 0, 1, 0, // alpha
            ]),
            child: Image.asset(
              "assets/images/background_img.jpg",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Logo with fade-in animation
          AnimatedBuilder(
            animation: _opacityAnimation,
            builder: (BuildContext context, Widget? child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Center(
                  child: Image.asset(
                    "assets/images/truck.png",
                    // fit: BoxFit.cover,
                    width: 300,
                    height: 400,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
