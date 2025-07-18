import 'dart:convert';
import 'package:dhadkan/features/doctor/home/DoctorHome.dart';
import 'package:dhadkan/utils/constants/colors.dart';
import 'package:dhadkan/utils/device/device_utility.dart';
import 'package:dhadkan/utils/http/http_client.dart';
import 'package:dhadkan/utils/storage/secure_storage_service.dart';
import 'package:dhadkan/utils/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;

class Patientadder extends StatefulWidget {
  const Patientadder({super.key});

  @override
  State<Patientadder> createState() => _PatientadderState();
}

class _PatientadderState extends State<Patientadder> {
  String _token = "";
  final TextEditingController nameController = TextEditingController();
  String? selectedGender;
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController uhidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool _obscurePassword = true;
  bool _isButtonLocked = false; // New state variable to lock button

  late stt.SpeechToText _speech;
  bool isListening = false;
  TextEditingController? currentListeningController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initialize();
  }

  Future<void> _initialize() async {
    String? token = await SecureStorageService.getData('authToken');
    if (mounted) {
      setState(() {
        _token = token ?? '';
      });
    }
    _generatePassword();
  }

  void startListening(TextEditingController controller) async {
    if (!await _speech.initialize(
      onStatus: (status) => print("Status: $status"),
      onError: (error) => print("Error: $error"),
    )) {
      print("Speech recognition is not available.");
      return;
    }

    setState(() {
      isListening = true;
      currentListeningController = controller;
    });

    _speech.listen(
      onResult: (result) {
        setState(() {
          String correctedText = result.recognizedWords.toLowerCase();
          correctedText = correctedText.replaceAll(RegExp(r'\bmail\b', caseSensitive: false), 'male');
          controller.text = correctedText;
        });
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 20),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (isListening && currentListeningController == controller) {
        stopListening();
      }
    });
  }

  void stopListening() {
    _speech.stop();
    setState(() {
      isListening = false;
      currentListeningController = null;
    });
  }

  void _generatePassword() {
    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();

    String firstName = name.split(' ').first.toLowerCase();
    String namePart = firstName.length >= 4
        ? firstName.substring(0, 4)
        : firstName;

    String mobileDigits = mobile.replaceAll(RegExp(r'[^0-9]'), '');
    String mobilePart = mobileDigits.length >= 4
        ? mobileDigits.substring(mobileDigits.length - 4)
        : mobileDigits;

    setState(() {
      passwordController.text = namePart + mobilePart;
    });
  }

  Future<void> handleAdd(BuildContext context) async {
    if (_isButtonLocked) return; // Prevent further clicks

    setState(() {
      _isButtonLocked = true; // Lock the button
    });

    final String name = nameController.text.trim();
    final String? gender = selectedGender;
    final String mobile = mobileController.text.trim();
    final String ageText = ageController.text.trim();
    final String uhidText = uhidController.text.trim();
    final String password = passwordController.text.trim();
    final String email = emailController.text.trim();

    if (name.isEmpty || mobile.isEmpty || gender == null || password.isEmpty || ageText.isEmpty || uhidText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      setState(() {
        _isButtonLocked = false; // Unlock on error
      });
      return;
    }

    int age;
    try {
      age = int.parse(ageText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid age')),
      );
      setState(() {
        _isButtonLocked = false; // Unlock on error
      });
      return;
    }
    int uhid;
    try {
      uhid = int.parse(uhidText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid uhid')),
      );
      setState(() {
        _isButtonLocked = false; // Unlock on error
      });
      return;
    }

    try {
      final response = await MyHttpHelper.private_post(
        '/doctor/addpatient',
        {
          'name': name,
          'mobile': mobile,
          'gender': gender,
          'age': age,
          'uhid': uhid,
          'password': password,
          'email': email
        },
        _token,
      );

      if (response['status'] == 'error') {
        if (response['message'] == 'Patient already exists') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This patient is already registered.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'An error occurred.')),
          );
        }
        setState(() {
          _isButtonLocked = false; // Unlock on error
        });
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient added successfully')),
      );

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DoctorHome()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during registration')),
      );
      setState(() {
        _isButtonLocked = false; // Unlock on error
      });
    }
  }

  Future<void> extractData(String voiceText) async {
    final url = Uri.parse("http://localhost:3000/api/extract-data");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"voice_text": voiceText}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Name: ${data['name']}");
        print("Mobile: ${data['mobile']}");
        print("Gender: ${data['gender']}");
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Failed to connect: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MyDeviceUtils.getScreenWidth(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sign-Up Information', style: MyTextTheme.textTheme.headlineSmall),
          const SizedBox(height: 10),
          _buildTextFormField(
            label: 'Name',
            controller: nameController,
            generatePasswordOnChange: true,
          ),
          const SizedBox(height: 20),
          _buildTextFormField(
            label: 'Phone Number',
            controller: mobileController,
            generatePasswordOnChange: true,
          ),
          const SizedBox(height: 20),
          _buildGenderDropdown(),
          const SizedBox(height: 20),
          _buildTextFormField(label: 'Age', controller: ageController),
          const SizedBox(height: 20),
          _buildTextFormField(label: 'UHID', controller: uhidController),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 20),
          _buildTextFormField(label: 'Email', controller: emailController),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isButtonLocked ? null : () => handleAdd(context), // Disable button if locked
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isButtonLocked
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'Add this Patient...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    bool generatePasswordOnChange = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.mic,
            color: (currentListeningController == controller && isListening)
                ? Colors.red
                : Colors.grey,
          ),
          onPressed: () {
            if (isListening && currentListeningController == controller) {
              stopListening();
            } else {
              startListening(controller);
            }
          },
        ),
      ),
      keyboardType: label == 'Age' || label == 'Phone Number'
          ? TextInputType.number
          : TextInputType.text,
      onChanged: (value) {
        if (generatePasswordOnChange) {
          _generatePassword();
        }
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: ['Male', 'Female', 'Other'].map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(
            gender,
            style: const TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedGender = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a gender';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.mic,
                color: (currentListeningController == passwordController && isListening)
                    ? Colors.red
                    : Colors.grey,
              ),
              onPressed: () {
                if (isListening && currentListeningController == passwordController) {
                  stopListening();
                } else {
                  startListening(passwordController);
                }
              },
            ),
          ],
        ),
      ),
      keyboardType: TextInputType.text,
    );
  }
}