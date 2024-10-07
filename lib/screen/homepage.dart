import 'package:easy_localization/easy_localization.dart';
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
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        centerTitle: false,
        leading: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(6), // Reduced padding to accommodate a larger logo
          margin: const EdgeInsets.all(10), // Adjusted margin for better spacing
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(50), // Adjusted for a larger circular shape
            backgroundBlendMode: BlendMode.colorBurn,
            image: const DecorationImage(
              image: AssetImage('assets/logo.jpg'),
              fit: BoxFit.cover, // Ensures the image fits well inside the container
            ),
          ),
        ),
        backgroundColor: AppColor.blueColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "វិទ្យាល័យសម្តេចឪ-ម៉ែ (រតនគិរី)",
              style: TextStyle(
                fontSize: 16, // Adjusted font size
                color: Colors.white, // Text color set to white
              ),
            ),
            Text(
              'Samdech Ov-Mae​ High School',
              style: TextStyle(
                fontSize: 14, // Adjusted font size
                color: Colors.white, // Text color set to white
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.notifications_active, color: Colors.white),
          SizedBox(width: 10,)
        ],
      ),
      body:Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              width: double.infinity,
              padding: EdgeInsets.only(top: 4, bottom: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  child: StreamBuilder<DateTime>(
                    stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                    builder: (context, snapshot) {
                      final dateTime = snapshot.data;
                      final formattedDateTime = dateTime != null
                          ? DateFormat('EEE, dd-MM-yyyy hh:mm:ss a').format(dateTime)
                          : 'Loading...';
                      return Text(
                        formattedDateTime,
                        textAlign: TextAlign.center,
                        style:  TextStyle (
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColor.primaryColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
