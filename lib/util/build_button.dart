import 'package:flutter/material.dart';
import 'package:som_mobile/const/app_color.dart';

class BuildButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  BuildButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: AppColor.blueColor, 
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
                fontFamily: 'Khmer'
            ),
          ),
        ),
      ),
    );
  }
}
