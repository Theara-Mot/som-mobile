import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:som_mobile/screen/admin/admin.dart';
import 'package:som_mobile/screen/auth/login.dart';
import 'package:som_mobile/screen/auth/signup.dart';
import 'package:som_mobile/screen/homepage.dart';
import 'package:som_mobile/screen/me.dart';
import 'package:som_mobile/screen/setting/class.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('km', 'KM'), Locale('ko', 'KR'),],
      path: 'assets/lang', 
      fallbackLocale: Locale('en', 'US'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? _user; // Variable to store the current user

  @override
  void initState() {
    super.initState();
    _checkUserStatus(); // Check user authentication status on initialization
  }

  void _checkUserStatus() {
    setState(() {
      _user = FirebaseAuth.instance.currentUser; // Get the currently signed-in user
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOM Mobile',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _user == null ? const LoginScreen() : const MainPage(), // Navigate based on login status
      routes: {

        '/signup': (context) => Signup(),
        '/home': (context) => const MainPage(), // Your home screen
        '/class': (context) => ClassPage(),
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
      const Homepage(), 
      AdminPage(),
      UserDataScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: tr('home'), 
        activeColorPrimary: Colors.deepPurple,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.admin_panel_settings_outlined),
        title: tr('admin'),  
        activeColorPrimary: Colors.deepPurple,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: tr('profile'),  
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
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true, 
      resizeToAvoidBottomInset: true, 
      stateManagement: true, 
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      navBarStyle: NavBarStyle.style1,
    );
  }
}
