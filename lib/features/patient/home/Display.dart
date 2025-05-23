import 'package:dhadkan_front/utils/theme/text_theme.dart';
import 'package:flutter/cupertino.dart';

class Display extends StatelessWidget {
  final data;
  const Display({super.key, required this.data});

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
          Text("UHID: ", style: MyTextTheme.textTheme.headlineSmall),
          Text(data['uhid'], style: MyTextTheme.textTheme.bodyMedium),
        ]),
        Row(children: [
          Text("Phone: ", style: MyTextTheme.textTheme.headlineSmall),
          Text(data['mobile']!, style: MyTextTheme.textTheme.bodyMedium),
        ]),
        Row(children: [
          Text("Doctor Mobile: ", style: MyTextTheme.textTheme.headlineSmall),
          Text(data['doctor']['mobile'], style: MyTextTheme.textTheme.bodyMedium),
        ]),
        Row(children: [
          Text("Disease: ", style: MyTextTheme.textTheme.headlineSmall),
          Text((data['otherDiagnosis']).toString(), style: MyTextTheme.textTheme.bodyMedium),
        ]),
      ],
    );
  }
}
