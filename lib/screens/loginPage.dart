import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:signin_signup/auth/firebase_auth_helper.dart';
import 'package:signin_signup/screens/ProfileScreen.dart';
import 'package:signin_signup/screens/registerPage.dart';
import 'package:signin_signup/auth/validator.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;

  String _errorMessage = '';

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: _initializeFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: _emailTextController,
                        focusNode: _focusEmail,
                        validator: (value) => Validator.validateEmail(
                          email: value,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          hintText: "Email",
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _passwordTextController,
                        focusNode: _focusPassword,
                        obscureText: true,
                        validator: (value) => Validator.validatePassword(
                          password: value,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          hintText: "Password",
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      _isProcessing
                          ? const CircularProgressIndicator()
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                if (_errorMessage.isNotEmpty)
                                  Text(
                                    _errorMessage,
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ElevatedButton(
                                  onPressed: () async {
                                    _focusEmail.unfocus();
                                    _focusPassword.unfocus();

                                    if (_formKey.currentState!.validate()) {
                                      try {
                                        setState(() {
                                          _isProcessing = true;
                                          _errorMessage = '';
                                        });

                                        User? user = await FirebaseAuthHelper
                                            .signInUsingEmailPassword(
                                          email: _emailTextController.text,
                                          password:
                                              _passwordTextController.text,
                                        );

                                        // setState(() {
                                        //   _isProcessing = false;
                                        // });
                                      } on FirebaseAuthException catch (e) {
                                        // Display an alert dialog containing the humanize error message
                                        _showErrorDialog(e);
                                        print('Test ${e.code}');
                                        setState(() {
                                          _isProcessing = false;
                                        });
                                      }
                                    }
                                  },
                                  child: const Text(
                                    'Sign In',
                                  ),
                                ),
                                const SizedBox(width: 24.0),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => RegisterPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'SignUp',
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 24.0),
                    ],
                  ),
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  //code of _showErrorDialog
  void _showErrorDialog(FirebaseAuthException e) {
    String errorMessage = '';
    switch (e.code) {
      // case error for registration
      case 'invalid-email':
        errorMessage = 'The email address is not valid.';
        break;
      case 'user-disabled':
        errorMessage = 'The user account has been disabled.';
        break;
      case 'user-not-found':
        errorMessage = 'The user account has not been found.';
        break;
      case 'wrong-password':
        errorMessage = 'Invalid password.';
        break;
      case 'email-already-in-use':
        errorMessage = 'An account already exists with that email address.';
        break;
      default:
        errorMessage = 'An undefined Error happened.';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
