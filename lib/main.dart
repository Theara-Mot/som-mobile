import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:som_mobile/screen/admin.dart';
import 'package:som_mobile/screen/auth/login.dart';
import 'package:som_mobile/screen/auth/signup.dart';
import 'package:som_mobile/screen/homepage.dart';
import 'package:som_mobile/screen/me.dart';

import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(), // Your login screen
        '/signup': (context) => const SignupScreen(), // Your signup screen
        '/home': (context) => const MainPage(), // Your home screen
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  PersistentTabController _controller;

  _MainPageState() : _controller = PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      const Homepage(),   // Replace with your actual homepage widget
      AdminPage(),
      const UserDataScreen(),  // Replace with your actual profile page
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: ("Home"),
        activeColorPrimary: Colors.deepPurple,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.admin_panel_settings_outlined),
        title: ("Admin"),
        activeColorPrimary: Colors.deepPurple,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: ("Profile"),
        activeColorPrimary: Colors.deepPurple,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      backgroundColor: Colors.white, // Default nav bar background color
      handleAndroidBackButtonPress: true, // Whether to handle Android back button
      resizeToAvoidBottomInset: true, // This needs to be true if you want to avoid overlapping of the bottom nav bar with the keyboard.
      stateManagement: true, // Whether you want to manage tabs state
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      navBarStyle: NavBarStyle.style1,
    );
  }
}
