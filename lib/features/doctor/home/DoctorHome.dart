import 'package:dhadkan_front/features/auth/LandingScreen.dart';
import 'package:dhadkan_front/features/common/TopBar.dart';
import 'package:dhadkan_front/features/doctor/home/Heading.dart';
import 'package:dhadkan_front/utils/storage/secure_storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utils/device/device_utility.dart';
import 'DoctorButtons.dart';
import 'Heading.dart';
import 'Histogram.dart';
import 'DoctorPie.dart';

class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

Future<void> _logout(BuildContext context) async {
  await SecureStorageService.deleteData('authToken');
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LandingScreen()),
    (Route<dynamic> route) => false,
  );
}


class _DoctorHomeState extends State<DoctorHome> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MyDeviceUtils.getScreenWidth(context);
    double paddingWidth = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const TopBar(title: "Welcome, Doctor"),
        actions: [
          IconButton(
            onPressed: () {
              _logout(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingWidth),
        child: const SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 15),
              Heading(),
              SizedBox(height: 15),
              DoctorButtons(),
              SizedBox(height: 15),
              // DoctorHistogram(),
              // SizedBox(height: 15),
              // DoctorPie(),
              // SizedBox(height: 15)
            ],
          ),
        ),
      ),
    );
  }
}
