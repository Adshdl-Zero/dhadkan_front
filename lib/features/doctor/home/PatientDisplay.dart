import 'package:dhadkan_front/utils/theme/text_theme.dart';
import 'package:flutter/cupertino.dart';

class PatientConatiner extends StatelessWidget {


  final data;

  const PatientConatiner({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(children: [
          Text("Name: ", style: MyTextTheme.textTheme.headlineSmall),
          Text(data['name']!, style: MyTextTheme.textTheme.bodyMedium),
        ]),
        Row(children: [
          Text("EDD: ", style: MyTextTheme.textTheme.headlineSmall),
          Text("14th Jan, 2019", style: MyTextTheme.textTheme.bodyMedium),
        ]),
        Row(children: [
          Text("Phone: ", style: MyTextTheme.textTheme.headlineSmall),
          Text(data['mobile']!, style: MyTextTheme.textTheme.bodyMedium),
        ]),
        Row(children: [
          Text("WHO Guide: ", style: MyTextTheme.textTheme.headlineSmall),
          Text("Following".toString(), style: MyTextTheme.textTheme.bodyMedium),
        ])
      ],
    );
  }
}