import 'package:dhadkan_front/features/common/TopBar.dart';
import 'package:dhadkan_front/features/patient/addData/CheckBox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utils/device/device_utility.dart';
import 'BP.dart';

class AddData extends StatelessWidget {
  const AddData({super.key});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MyDeviceUtils.getScreenWidth(context);
    var paddingWidth = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const TopBar(title: "Add Data"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingWidth),
        child: const SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 15),
              BP()

            ],
          ),
        ),
      ),
    );
  }
}
