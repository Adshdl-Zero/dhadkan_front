import 'package:dhadkan_front/features/doctor/home/DoctorButton.dart';
import 'package:dhadkan_front/utils/device/device_utility.dart';
import 'package:dhadkan_front/utils/theme/text_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DoctorButtons extends StatelessWidget {
  const DoctorButtons({super.key});
  @override
  Widget build(BuildContext context) {
    void handleAllPatientPress() {
      Navigator.pushNamed(context, 'doctor/allpatient/');
    }
    void handleAddPatientPress() {
      Navigator.pushNamed(context, 'doctor/addpatient/');
    }
    void handleAdddrugPatientPress() {
      Navigator.pushNamed(context, 'doctor/adddrugpatient/');
    }
    var screenWidth = MyDeviceUtils.getScreenWidth(context);
    var width = screenWidth * 0.9;
    return Container(
      width: width,
      height: 60,
      decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Doctorbutton(
              title: "All Patients", handleClick: handleAllPatientPress),
          const SizedBox(
            width: 25,
          ),
          Doctorbutton(
              title: "Add Patient", handleClick: handleAddPatientPress),
          // const SizedBox(
          //   width: 25,
          // ),
          // Doctorbutton(
          //     title: "Add Data", handleClick: handleAdddrugPatientPress),
        ],
      ),
    );
  }
}
