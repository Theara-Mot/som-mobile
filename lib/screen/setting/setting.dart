import 'package:flutter/material.dart';
import 'package:som_mobile/const/app_color.dart';
import 'package:som_mobile/screen/setting/class.dart';
import 'package:som_mobile/screen/setting/department.dart';
import 'package:som_mobile/screen/setting/level.dart';
import 'package:som_mobile/screen/setting/role.dart';
import 'package:som_mobile/screen/setting/subject.dart';
import 'package:som_mobile/screen/setting/user.dart';

class SettingsPage extends StatelessWidget {
  List settingsList = [
    {'name': 'Level',
      'description': 'Manage your class settings',
      'page': LevelPage(),
    },
    {'name': 'Class',
      'description': 'Manage your class settings',
      'page': ClassPage(),
    },
    {'name': 'departments',
      'description': 'Manage your class settings',
      'page': DepartmentPage(),
    },
    {'name': 'Role',
      'description': 'Manage your class settings',
      'page': RolePage(),
    },
    {'name': 'Subject',
      'description': 'Manage your class settings',
      'page': SubjectPage(),
    },
    {'name': 'User',
      'description': 'Manage your class settings',
      'page': UserPage(),
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: Column(
          children: settingsList.map((setting) {
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 8,right: 8,top: 8),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color:Colors.blue.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(0, 0), // changes position of shadow
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (BuildContext context) {
                      return setting['page'];
                    }),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      setting['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            setting['description'],
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,color: Colors.grey,)
                      ],
                    ),
                  ],
                )
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
