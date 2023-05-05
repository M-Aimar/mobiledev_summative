import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth.dart';
import 'dart:async';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  String? errorMessage = '';
  bool _loading = true;
  final _formKey = GlobalKey<FormState>();
  Timer? _debounceTimer;
  final textFormFieldFocusNode = FocusNode();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final Map<String, bool> _isControllerEmpty = {
    "firstName": true,
    'lastName': true,
    'email': true,
    'phoneNumber': true,
    'password': true,
  };

  Future<void> signInWithEmailAndPassword() async {
    try {
      setState(() {
        _loading = true;
      });

      await Auth().signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      Navigator.pushNamed(context, '/home');
      errorMessage = '';
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = 'Invalid Credentials';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String uid = DateTime.now().microsecondsSinceEpoch.toString();
  Future<void> createUser() async {
    try {
      setState(() {
        _loading = true;
      });
      await Auth().createUser(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
        password: _passwordController.text,
        uid: uid,
      );
      setState(() {
        _isLogin = true;
      });
      Fluttertoast.showToast(
          msg: 'Registration successful',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String _toCamelCase(String input) {
    if (input.isEmpty) {
      return input;
    }
    final words = input.split(" ");
    final firstWord = words.first.toLowerCase();
    final restOfWords = words.skip(1);
    return "$firstWord${restOfWords.map((word) => "${word[0].toUpperCase()}${word.substring(1)}").join("")}";
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isLogin) {
      await signInWithEmailAndPassword();
      return;
    }

    await createUser();
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
    String controllerName,
  ) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: TextFormField(
            controller: controller,
            style: GoogleFonts.montserrat(
              textStyle: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                color: Color(0xffffffff),
              ),
            ),
            decoration: InputDecoration(
                hintText: title,
                contentPadding:
                    const EdgeInsets.only(left: 20, bottom: 10, top: 10),
                hintStyle: GoogleFonts.montserrat(
                  textStyle: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.normal,
                    color: Color(0xffffffff),
                  ),
                ),
                labelText: _isControllerEmpty.containsKey(controllerName) &&
                        _isControllerEmpty[controllerName] != true
                    ? null
                    : title.toLowerCase(),
                labelStyle: GoogleFonts.montserrat(
                  textStyle: const TextStyle(
                      fontSize: 20.0,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(100)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 79, 77, 77)),
                    borderRadius: BorderRadius.circular(100))),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your $title';
              }
              return null;
            },
            obscureText: title.toLowerCase().trim() == 'password',
            onChanged: (value) {
              _isControllerEmpty[controllerName] = value == "";
            }));
  }

  Widget _errorMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        errorMessage ?? '',
        style: const TextStyle(
          color: Colors.red,
          fontSize: 16.0,
        ),
      ),
    );
  }

  Widget _forgotPasswordButton() {
    return Column(children: [
      const SizedBox(height: 20),
      TextButton(
          onPressed: () {},
          child: Text(
            'Forgot your password?',
            style: GoogleFonts.montserrat(
              textStyle: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
                color: Color(0xffffffff),
              ),
            ),
          ))
    ]);
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: () => handleSubmit(),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffffffff),
        foregroundColor: const Color(0xff13B58C),
        minimumSize: const Size.fromHeight(45),
        shape: const StadiumBorder(),
      ),
      child: _loading
          ? const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              _isLogin ? 'Login' : 'Create',
              style: GoogleFonts.montserrat(
                textStyle: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ),
    );
  }

  Widget _loginOrRegisterButton() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Text(_isLogin ? "Don't have an account?" : "Have an account?",
          style: GoogleFonts.montserrat(
            textStyle: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.normal,
              color: Colors.green,
            ),
          )),
      TextButton(
          onPressed: () {
            setState(() {
              _isLogin = !_isLogin;
              _resetForm();
              _formKey.currentState?.reset();
              errorMessage = '';
            });
          },
          child: Text(
            _isLogin ? 'Sign Up' : 'Sign In',
            style: GoogleFonts.montserrat(
              textStyle: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                color: Colors.green,
              ),
            ),
          ))
    ]);
  }

  void _resetForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _phoneNumberController.clear();
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff13B58C),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: _isLogin ? 173 : 30),
                            child: Text(
                              "Welcome to Rush Grocery",
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  color: Color(0xffffffff),
                                ),
                              ),
                            )),
                        if (!_isLogin)
                          Padding(
                              padding:
                                  const EdgeInsets.only(top: 30, bottom: 30),
                              child: Text(
                                "Create an Account",
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w300,
                                    fontStyle: FontStyle.normal,
                                    color: Colors.green,
                                  ),
                                ),
                              )),
                        if (_isLogin)
                          Padding(
                              padding:
                                  const EdgeInsets.only(top: 85, bottom: 35),
                              child: Text(
                                "Login to your account",
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FontStyle.normal,
                                    color: Colors.green,
                                  ),
                                ),
                              )),
                        if (!_isLogin)
                          _entryField(
                              'First Name', _firstNameController, 'firstName'),
                        if (!_isLogin)
                          _entryField(
                              'Last Name', _lastNameController, 'lastName'),
                        if (!_isLogin)
                          _entryField('Phone Number', _phoneNumberController,
                              'phoneNumber'),
                        _entryField(
                            'Email Address', _emailController, 'emailAddress'),
                        _entryField(
                            'Password', _passwordController, 'password'),
                        _errorMessage(),
                        _submitButton(),
                        if (_isLogin) _forgotPasswordButton(),
                        _loginOrRegisterButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
