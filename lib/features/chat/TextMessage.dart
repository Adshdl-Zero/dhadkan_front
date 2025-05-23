import 'package:dhadkan_front/utils/constants/colors.dart';
import 'package:dhadkan_front/utils/device/device_utility.dart';
import 'package:dhadkan_front/utils/theme/text_theme.dart';
import 'package:flutter/cupertino.dart';

class TextMessage extends StatelessWidget {
  final String text;
  final bool mine;

  const TextMessage({super.key, required this.text, required this.mine});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MyDeviceUtils.getScreenWidth(context);
    double maxWidth = screenWidth * 0.7;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0), // Equal padding on all sides
              child: Text(
                text,
                style: MyTextTheme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}