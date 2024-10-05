import 'package:flutter/material.dart';
import 'package:som_mobile/const/app_color.dart';
import 'package:som_mobile/util/build_appbar.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: BuildAppbar(title: 'SOM Mobile'),
  body: Center(child: Text('Welcome to the homepage!')),
);
  }
}
