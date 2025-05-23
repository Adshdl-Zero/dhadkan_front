import 'package:dhadkan_front/utils/device/device_utility.dart';
import 'package:dhadkan_front/utils/theme/text_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HistoryBox extends StatelessWidget {
  final data;
  const HistoryBox({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MyDeviceUtils.getScreenWidth(context);
    var width = screenWidth * 0.9;

    return Container(
        padding: const EdgeInsets.only(left: 20, right: 25),
        height: 100,
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(data['date'], style: MyTextTheme.textTheme.headlineMedium),
                    // Text("2024", style: MyTextTheme.textTheme.bodyMedium),
                    Text(data['time'], style: MyTextTheme.textTheme.titleSmall),
                  ],
                ),
                const SizedBox(width: 10),

                Container(width: 0.7, height: 80, color: Colors.black54,),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Systolic BP: ${data['sbp']}",
                        style: MyTextTheme.textTheme.titleSmall),
                    Text("Diastolic BP: ${data['dbp']}",
                        style: MyTextTheme.textTheme.titleSmall),
                    Text("Weight: ${data['weight']}", style: MyTextTheme.textTheme.titleSmall),
                  ],
                ),
              ],
            ),

            // SizedBox(width: 20),
            Text("🔥", style: const TextStyle().copyWith(fontSize: 40))
          ],
        ));
  }
}
