import 'package:dhadkan_front/Custom/CustomElevatedButton.dart';
import 'package:dhadkan_front/features/auth/DoctorSignUpScreen.dart';
import 'package:dhadkan_front/features/auth/PatientSignUpScreen.dart';
import 'package:dhadkan_front/features/auth/SelectionScreen.dart';
import 'package:dhadkan_front/features/common/Wrapper.dart';
import 'package:dhadkan_front/features/doctor/home/DoctorHome.dart';
import 'package:dhadkan_front/features/patient/home/PatientHomeScreen.dart';
import 'package:dhadkan_front/utils/constants/colors.dart';
import 'package:dhadkan_front/utils/device/device_utility.dart';
import 'package:dhadkan_front/utils/helpers/helper_functions.dart';
import 'package:dhadkan_front/utils/http/http_client.dart';
import 'package:dhadkan_front/utils/storage/secure_storage_service.dart';
import 'package:dhadkan_front/utils/theme/text_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true; // New state variable for password visibility

  Future<void> handleLogin(BuildContext context) async {
    final String mobile = mobileController.text.trim();
    final String password = passwordController.text;

    if (mobile.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')));
      return;
    }
    try {
      Map<String, dynamic> response = await MyHttpHelper.post(
          '/auth/login', {'mobile': mobile, 'password': password});
      if (response['success'] == "true") {
        String token = response['message'];
        String role = getRole(token);
        await SecureStorageService.storeData('authToken', token);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Login Successful!")));
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) =>
          role == "patient" ?  const PatientHome() :  const DoctorHome()),
              (Route<dynamic> route) => false,
        );

      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(response['message'])));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred during login.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MyDeviceUtils.getScreenWidth(context);

    return Scaffold(
        body: Wrapper(
            top: 100,
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Dhadkan',
                      style:
                      TextStyle(fontSize: 36, fontWeight: FontWeight.w600)),
                  Text('App for Heart Disease',
                      style: MyTextTheme.textTheme.bodyMedium)
                ]),
                const SizedBox(width: 10),
                Image.asset('assets/Images/logo.png',
                    height: 70, width: 70, fit: BoxFit.cover),
              ]),
              const SizedBox(height: 55),
              Text('Login', style: MyTextTheme.textTheme.headlineLarge),
              const SizedBox(height: 24),
              TextFormField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                style: MyTextTheme.textTheme.headlineSmall,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Phone Number',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.phone),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 17, horizontal: 10),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword, // Use the state variable here
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: MyColors.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword; // Toggle visibility
                      });
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 10),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: screenWidth * 0.9,
                height: 50,
                child: CustomElevatedButton(
                    height: 50,
                    width: 20,
                    onPressed: () => handleLogin(context),
                    text: 'Login'),
              ),
              const SizedBox(height: 24),
              Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: MyTextTheme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SelectionScreen(),
                                  ));
                            },
                            child: Text('Sign Up',
                                style: MyTextTheme.textTheme.headlineSmall))
                      ]))
            ])));
  }

  @override
  void dispose() {
    mobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}