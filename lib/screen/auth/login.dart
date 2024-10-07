import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:som_mobile/const/app_color.dart';
import 'package:som_mobile/util/build_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool _obscureText = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _emailTimer;
  String _version = '';
  String _app_name = '';
  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _loadVersion();
  }
  Future<void> _loadVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    // Print all the details
    print('App Name: $appName');
    print('Package Name: $packageName');
    print('Version: $version');
    print('Build Number: $buildNumber');

    setState(() {
      _version = version;
      _app_name = appName;
    });
  }



  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _saveToSharedPreferences();

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else {
        errorMessage = e.message ?? 'An unknown error occurred.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Future<void> _saveToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userType = passwordController.text.toLowerCase();

    if (userType == 'user' || userType == 'admin') {
      await prefs.setString('userType', userType);
    } else {
      print('Invalid user type entered');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor:AppColor.bgColor,
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                ClipOval(
                  child: Image.asset(
                    'assets/logo.jpg', // Your logo file path
                    height: 100, // Set logo height
                    width: 100,  // Set width to match the height for a perfect circle
                    fit: BoxFit.cover, // Ensures the image fits within the circle
                  ),
                ),
                SizedBox(height: 20),
                const Text(
                  'Samdech Ov-Mae',
                  style: TextStyle(
                    fontFamily: 'English',
                    fontSize: 35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Text(
                  'High School',
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'English',
                  ),
                ),
                const SizedBox(height: 50),
                Card(
                  color: Colors.white,
                  elevation: 0, // No shadow or raised effect
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8,right: 8,top: 8),
                    child: TextFormField(
                      style: TextStyle(fontFamily: 'English'),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(fontFamily: 'English'),
                        hintText: 'Enter your email', // The hint inside the text field
                        border: InputBorder.none, // No visible border for the TextFormField
                        prefixIcon: Icon(Icons.alternate_email, size: 25, color: Colors.black54),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _emailTimer?.cancel();
                        _emailTimer = Timer(Duration(seconds: 3), () {
                          if (value.length >= 3 && !value.contains('@')) {
                            emailController.text = value + '@gmail.com';
                            emailController.selection = TextSelection.fromPosition(
                              TextPosition(offset: emailController.text.length),
                            );
                          }
                        });
                      },
                    ),
                  ),
                ),
                Card(
                  color: Colors.white,
                  elevation: 0, // No shadow or raised effect
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8,right: 8,top: 8),
                    child: TextFormField(
                      style:  TextStyle(fontFamily: 'English'),
                      keyboardType: TextInputType.visiblePassword,
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintStyle:  TextStyle(fontFamily: 'English'),
                        hintText: 'Enter your password',
                        border: InputBorder.none, // No visible border for the TextFormField
                        prefixIcon: const Icon(Icons.lock_outlined, size: 25, color: Colors.black54),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                            size: 25,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                BuildButton(text: 'Login', onPressed: _login),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text('Don\'t have an account? Sign up',style:  TextStyle(fontFamily: 'English'),),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_app_name | ',
                      style: TextStyle(color: Colors.grey,fontFamily: 'English'),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Version $_version',
                      style: TextStyle(color: Colors.grey,fontFamily: 'English'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
