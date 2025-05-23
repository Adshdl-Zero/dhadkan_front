import 'package:dhadkan_front/features/common/Graph.dart';
import 'package:dhadkan_front/utils/constants/colors.dart';
import 'package:dhadkan_front/utils/device/device_utility.dart';
import 'package:dhadkan_front/utils/helpers/helper_functions.dart';
import 'package:dhadkan_front/utils/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PatientGraph extends StatelessWidget {
  final Map<String, dynamic> graphData;

  const PatientGraph({super.key, required this.graphData});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MyDeviceUtils.getScreenWidth(context);
    double width = screenWidth * 0.95;

    List<double> xValues = [];
    List<double> diastolic = convertType(graphData['dbp']);
    List<double> systolic = convertType(graphData['sbp']);
    List<double> weight = convertType(graphData['weight']);

    for (int i = 0; i < diastolic.length; i++) {
      xValues.add(i.toDouble());
    }
    
    return Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Graph(
            times: xValues,
            diastolic: diastolic,
            systolic: systolic,
            weight: weight,
            width: width - 20));
  }

  static List<double> convertType(List<dynamic> arr) {
    return arr.map((e) {
      if (e is num) {
        return e.toDouble();
      } else if (e is String) {
        return double.tryParse(e) ?? 0.0;
      } else {
        return 0.0;
      }
    }).toList();
  }
}
