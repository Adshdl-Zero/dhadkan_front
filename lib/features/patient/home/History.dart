import 'package:dhadkan_front/features/patient/home/HistoryBox.dart';
import 'package:dhadkan_front/utils/constants/colors.dart';
import 'package:dhadkan_front/utils/device/device_utility.dart';
import 'package:flutter/material.dart';

class History extends StatefulWidget {
  final List<dynamic> history;
  const History({super.key, required this.history});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {


  @override
  Widget build(BuildContext context) {
    var screenWidth = MyDeviceUtils.getScreenWidth(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(

        children: [
          for (var item in widget.history)
            Column(
              children: [
                HistoryBox(
                  data: item,
                ),
                Container(
                  width: screenWidth * 0.8,
                  height: 0.5,
                  color: MyColors.primary,
                ),

      
              ],
            )
        ],
      ),
    );
  }
}
