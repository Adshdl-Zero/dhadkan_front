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

    // Convert the data to match the format expected by Graph widget
    // The graphData now comes in format: {'sbp': [], 'dbp': [], 'weight': []}
    List<double> diastolic = convertType(graphData['dbp']);
    List<double> systolic = convertType(graphData['sbp']);
    List<double> weight = convertType(graphData['weight']);

    // Generate x-values based on the length of the data
    // Use the maximum length among all data arrays to ensure proper indexing
    int maxLength = [diastolic.length, systolic.length, weight.length]
        .reduce((a, b) => a > b ? a : b);

    List<double> xValues = [];
    for (int i = 0; i < maxLength; i++) {
      xValues.add(i.toDouble());
    }

    // Ensure all arrays have the same length by padding with zeros if necessary
    while (diastolic.length < maxLength) {
      diastolic.add(0.0);
    }
    while (systolic.length < maxLength) {
      systolic.add(0.0);
    }
    while (weight.length < maxLength) {
      weight.add(0.0);
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

  static List<double> convertType(List<dynamic>? arr) {
    // Handle null or empty arrays
    if (arr == null || arr.isEmpty) {
      return [];
    }

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