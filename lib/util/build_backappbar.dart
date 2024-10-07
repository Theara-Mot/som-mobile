import 'package:flutter/material.dart';

class BuildBackAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final VoidCallback? onActionPressed; // Optional callback for action button
  final IconData? actionIcon; // Optional icon for the action button

  BuildBackAppbar({
    required this.title,
    this.backgroundColor = const Color.fromARGB(255, 9, 47, 100),
    this.onActionPressed, // Initialize optional action callback
    this.actionIcon, // Initialize optional action icon
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      title: Text(
        title,
        style: TextStyle(color: Colors.white,fontFamily: 'Khmer', ),
      ),
      centerTitle: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {
          Navigator.of(context).pop(); // Navigate back when pressed
        },
      ),
      actions: [
        if (onActionPressed != null && actionIcon != null) // Check if action is defined
          IconButton(
            icon: Icon(actionIcon, color: Colors.white), // Use the icon passed in
            onPressed: onActionPressed, // Call the action when pressed
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
