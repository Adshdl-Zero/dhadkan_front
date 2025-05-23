import 'package:dhadkan_front/utils/theme/text_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utils/device/device_utility.dart';

class CheckBox extends StatelessWidget {
  const CheckBox({super.key});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MyDeviceUtils.getScreenWidth(context);
    var width = screenWidth * 0.9;

    return Container(
      width: width,
      // height: 200,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Select ",
                style: MyTextTheme.textTheme.headlineLarge),
            SizedBox(
                height: 30,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Headache',
                    style: MyTextTheme.textTheme.bodyMedium,
                  ),
                  value: false,
                  onChanged: (bool? value) {},
                )),
            SizedBox(
                height: 30,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Abdominal Pain',
                    style: MyTextTheme.textTheme.bodyMedium,
                  ),
                  value: false,
                  onChanged: (bool? value) {},
                )),
            SizedBox(
                height: 30,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Visual Problems',
                    style: MyTextTheme.textTheme.bodyMedium,
                  ),
                  value: false,
                  onChanged: (bool? value) {},
                )),
            SizedBox(
                height: 30,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Decreased Fetal Movements',
                    style: MyTextTheme.textTheme.bodyMedium,
                  ),
                  value: false,
                  onChanged: (bool? value) {},
                )),
            SizedBox(
                height: 30,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Swelling in Hands or Face',
                    style: MyTextTheme.textTheme.bodyMedium,
                  ),
                  value: false,
                  onChanged: (bool? value) {},
                )),
          ],
        ),
      ),
    );
  }
}
