import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
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
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  'App Name',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w400,
                    color: Colors.deepPurple,
                  ),
                ),
                const Text(
                  'Company Name',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 80),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.person_outline, size: 30, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        size: 30,
                        color: Colors.black54,
                      ),
                    ),
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outlined, size: 30, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text('Don\'t have an account? Sign up'),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Developer Name',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Version 1.1.1',
                      style: TextStyle(color: Colors.grey),
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
