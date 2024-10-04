import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController levelController = TextEditingController();
  final TextEditingController mainSubjectController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    genderController.dispose();
    dobController.dispose();
    phoneController.dispose();
    levelController.dispose();
    mainSubjectController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      print("Creating user...");
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("User created. Saving to Firestore...");
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'name': nameController.text.trim(),
        'gender': genderController.text.trim(),
        'dob': DateTime.parse(dobController.text.trim()),
        'joinDate': DateTime.now(),
        'phone': phoneController.text.trim(),
        'level': levelController.text.trim(),
        'mainSubject': mainSubjectController.text.trim(),
      });

      print("User data saved. Navigating to home...");
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.message ?? 'An unknown error occurred.';
      print(errorMessage); // Print error message to console
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      print("Error: $e"); // Catch any other errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: genderController,
              decoration: const InputDecoration(labelText: 'Gender'),
            ),
            TextField(
              controller: dobController,
              decoration: const InputDecoration(labelText: 'Date of Birth'),
              readOnly: true,
              onTap: () async {
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  dobController.text = '${selectedDate.toLocal()}'.split(' ')[0]; // Format: YYYY-MM-DD
                }
              },
            ),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: levelController,
              decoration: const InputDecoration(labelText: 'Level'),
            ),
            TextField(
              controller: mainSubjectController,
              decoration: const InputDecoration(labelText: 'Main Subject'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signup,
              child: const Text('Signup'),
            ),
          ],
        ),
      ),
    );
  }
}
