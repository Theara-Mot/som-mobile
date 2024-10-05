import 'package:flutter/material.dart';

class BuildAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;

  BuildAppbar({required this.title, this.backgroundColor = const Color.fromARGB(255, 9, 47, 100)});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
