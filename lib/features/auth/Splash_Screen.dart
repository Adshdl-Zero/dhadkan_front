import 'dart:async';

import 'package:dhadkan_front/features/auth/LandingScreen.dart';
import 'package:dhadkan_front/features/doctor/home/DoctorHome.dart';
import 'package:dhadkan_front/features/patient/home/PatientHomeScreen.dart';
import 'package:dhadkan_front/utils/helpers/helper_functions.dart';
import 'package:dhadkan_front/utils/http/http_client.dart';
import 'package:flutter/material.dart';
import 'package:dhadkan_front/utils/storage/secure_storage_service.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState(){
    super.initState();
    _checkLoginStatus();
  }


  // Function to check if the user is already logged in
  void _checkLoginStatus() async {
    String? token = await SecureStorageService.getData('authToken');

    if (token != null) {
      bool isValid = await _validateToken(token);

      Timer(const Duration(seconds: 2), () async {
        if (isValid) {
                  String role = getRole(token);
                          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => 
              role == "patient" ?  const PatientHome() :  const DoctorHome()),
            (Route<dynamic> route) => false,
          );

        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LandingScreen()),
          );
        }
      });
    } else {
      Timer(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LandingScreen()),
        );
      });
    }
  }

  Future<bool> _validateToken(String token) async {
  try {
    final response = await MyHttpHelper.private_get(
      '/patient/validate-token',
      token
    );

    if (response['status'] == 'valid') {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print('Error validating token: $e');
    return false;
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/Images/logo.png'),
      ),
    );
  }
}