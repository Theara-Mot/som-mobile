import 'package:flutter/material.dart';

Widget buildTextField({
  required String labelText,
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  void Function(String)? onChanged,
  IconData? icon,
}) {
  return Card(
    color: Colors.white,
    child: TextField(
      style: TextStyle(fontFamily: 'Khmer'),
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        suffixIcon: Icon(icon,size: 20,color: Colors.grey,),
        hintStyle: TextStyle(fontFamily: 'Khmer'),
        hintText: labelText,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}
