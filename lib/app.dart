import 'package:dhadkan_front/features/auth/LandingScreen.dart';
import 'package:dhadkan_front/features/auth/Splash_Screen.dart';
import 'package:dhadkan_front/features/chat/ConversationScreen.dart';
import 'package:dhadkan_front/features/doctor/home/DoctorHome.dart';
import 'package:dhadkan_front/features/doctor/home/drug.dart/adddrug.dart';
import 'package:dhadkan_front/features/doctor/home/addpatient.dart';
import 'package:dhadkan_front/features/doctor/home/allPatientsPage.dart';
// import 'package:dhadkan_front/features/doctor/patientList/PatientList.dart';
import 'package:dhadkan_front/features/patient/addData/AddDataScreen.dart';
import 'package:dhadkan_front/features/patient/home/PatientHomeScreen.dart';
// import 'package:dhadkan_front/features/patient/tests/TestsScreen.dart';
import 'package:dhadkan_front/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:dhadkan_front/features/report/Report.dart'; // Add this import
import 'package:dhadkan_front/features/report/UploadReport.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dhadkan',
      themeMode: ThemeMode.light,
      theme: MyTheme.myTheme,
      darkTheme: MyTheme.myTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        'landing': (context) => const LandingScreen(),
        'patient/home/': (context) => const PatientHome(),
        'patient/add/': (context) => const AddData(),
        // 'patient/tests/': (context) => const TestsScreen(),
        'doctor/home/': (context) => const DoctorHome(),
        // 'doctor/all-patients': (context) => const PatientList(),
        'doctor/addpatient/': (context) => const AddPatient(),
        'doctor/allpatient/': (context) => const AllPatientsPage(),
        'doctor/adddrugpatient/': (context) {
          final patientMobile = ModalRoute.of(context)!.settings.arguments as String;
          return AddDrugPage(patientMobile: patientMobile);
        },
        'chat/': (context) {
          final receiverId = ModalRoute.of(context)!.settings.arguments as String;
          return ConversationScreen(receiver_id: receiverId);
        },
        'reports/': (context) {
          final patientId = ModalRoute.of(context)!.settings.arguments as String;
          return ReportPage(patientId: patientId);
        },
        'reports/upload/': (context) {
          final patientId = ModalRoute.of(context)!.settings.arguments as String;
          return UploadReportPage(patientId: patientId);
        },
      },
      onUnknownRoute: (settings) {
        // Fallback route when no named route matches
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
      },
    );
  }
}