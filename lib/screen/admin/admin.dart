import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:som_mobile/const/app_color.dart';
import 'package:som_mobile/screen/admin/add_schedule.dart';
import 'package:som_mobile/screen/setting/setting.dart';

import 'user/user_detail.dart';
import 'user/user.dart';
class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor:Colors.grey.shade200,
        appBar: AppBar(
          toolbarHeight: 30,
          centerTitle: false,
          backgroundColor: AppColor.blueColor,
          title: const Text('Admin Page',style: TextStyle(color: Colors.white),),
          bottom: const TabBar(
            labelColor:Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'User'),
              Tab(text: 'Schedule'),
              Tab(text: 'Setting'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            UserListTab(),
            AddSchedule(),
            SettingsPage()
          ],
        ),
      ),
    );
  }
}

