import 'dart:io';

import 'package:dhadkan_front/Custom/CustomElevatedButton.dart';
import 'package:dhadkan_front/utils/theme/text_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/device/device_utility.dart';
import '../../../utils/http/http_client.dart';
import '../../../utils/storage/secure_storage_service.dart';


class BP extends StatefulWidget {
  const BP({super.key});

  @override
  State<BP> createState() => _BPState();
}

class _BPState extends State<BP> {
  String _token = "";

  final TextEditingController dbpController = TextEditingController();
  final TextEditingController sbpController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    dbpController.dispose();
    sbpController.dispose();
    weightController.dispose();
    super.dispose();
  }

  _initialize() async {
    String? token = await SecureStorageService.getData('authToken');
    setState(() {
      _token = token ?? '';
    });
  }

  Future<void> handleSubmit(BuildContext context) async {
    String dbp = dbpController.text.trim();
    String sbp = sbpController.text.trim();
    String weight = weightController.text.trim();

    if (sbp.isEmpty || dbp.isEmpty || weight.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      Map<String, dynamic> response = await MyHttpHelper.private_post(
          '/patient/add', {'sbp': sbp, 'dbp': dbp, 'weight': weight}, _token);
      if (response['success'] == "true") {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(response['message'])));
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(response['message'])));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Some error occurred.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MyDeviceUtils.getScreenWidth(context);
    var width = screenWidth * 0.9;

    return Container(
      width: width,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text("Blood Pressure", style: MyTextTheme.textTheme.headlineLarge),
            // SizedBox(height: 20),
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Systolic BP: "),
                  const SizedBox(width: 22),
                  Expanded(
                      child: Container(
                    // height: 30,
                    child: TextField(
                      controller: sbpController,
                      style: MyTextTheme.textTheme.bodyMedium,
                      cursorHeight: 16,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter here',
                        isDense: true,
                        border: UnderlineInputBorder(),
                        // Bottom line only
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2), // Customize color and thickness
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1), // Customize color and thickness
                        ),

                        contentPadding: EdgeInsets.symmetric(
                          // vertical: 5,
                          // Set height by adjusting vertical padding
                          horizontal: 10, // Set horizontal padding
                        ),
                      ),
                    ),
                  ))
                ]),
            const SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Diastolic BP: "),
                  const SizedBox(width: 15),
                  Expanded(
                      child: Container(
                    // width: 50,
                    // height: 50,
                    child: TextField(
                      controller: dbpController,
                      style: MyTextTheme.textTheme.bodyMedium,
                      cursorHeight: 16,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter here',
                        isDense: true,
                        border: UnderlineInputBorder(),
                        // Bottom line only
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2), // Customize color and thickness
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1), // Customize color and thickness
                        ),

                        contentPadding: EdgeInsets.symmetric(
                          // vertical: 5,
                          // Set height by adjusting vertical padding
                          horizontal: 10, // Set horizontal padding
                        ),
                      ),
                    ),
                  ))
                ]),
            const SizedBox(height: 20),
            Row(children: [
              const Text("Weight: "),
              const SizedBox(width: 50),
              Expanded(
                  child: SizedBox(
                width: 100,
                // height: 30,
                child: TextField(
                  controller: weightController,
                  style: MyTextTheme.textTheme.bodyMedium,
                  keyboardType: TextInputType.number,
                  cursorHeight: 16,
                  decoration: const InputDecoration(
                    hintText: 'Enter here',
                    isDense: true,
                    border: UnderlineInputBorder(),
                    // Bottom line only
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2), // Customize color and thickness
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1), // Customize color and thickness
                    ),

                    contentPadding: EdgeInsets.symmetric(
                      // vertical: 5,
                      // Set height by adjusting vertical padding
                      horizontal: 10, // Set horizontal padding
                    ),
                  ),
                ),
              ))
            ]),
            const SizedBox(height: 25),
            CustomElevatedButton(
              text: "Add Data",
              onPressed: () => handleSubmit(context),
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
