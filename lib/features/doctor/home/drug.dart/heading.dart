// import 'package:dhadkan_front/features/patient/home/Display.dart';
// import 'package:dhadkan_front/utils/device/device_utility.dart';
// import 'package:dhadkan_front/utils/helpers/helper_functions.dart';
// import 'package:dhadkan_front/utils/http/http_client.dart';
// import 'package:dhadkan_front/utils/storage/secure_storage_service.dart';
// import 'package:dhadkan_front/utils/theme/text_theme.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class Heading extends StatefulWidget {
//   const Heading({super.key});

//   @override
//   _HeadingState createState() => _HeadingState();
// }

// class _HeadingState extends State<Heading> {
//   String _token = "";

//   Map<String, dynamic> patientDetails = {
//     "name": " ",
//     "mobile": " ",
//     "age": " ",
//   };

//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }

//   _initialize() async {
//     String? token = await SecureStorageService.getData('authToken');
//     setState(() {
//       _token = token ?? '';
//     });

//     try {
//       Map<String, dynamic> response = await MyHttpHelper.private_post(
//           '/auth/get-details', {}, _token);
//       if (response['success'] == 'true'){
//         setState(() {
//           patientDetails = response['data'];

//           print(response['data']);
//           print('huehuehue');
//         });
//         return;
//       }
//     }catch(e){
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Error in loading_data")));
//       print(e);
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MyDeviceUtils.getScreenWidth(context);
//     double width = screenWidth * 0.9;

//     return Container(
//       height: 140,
//       width: width,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               height: 90,
//               width: 90,

//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: BorderRadius.circular(50),
//               ),
//               child: ClipOval(
//                 child: Image.network(
//                   "https://play-lh.googleusercontent.com/LeX880ebGwSM8Ai_zukSE83vLsyUEUePcPVsMJr2p8H3TUYwNg-2J_dVMdaVhfv1cHg=w240-h480-rw",
//                   height: 50,
//                   width: 50,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 20),
//             Display(data: patientDetails),
//           ],
//         ),
//       ),
//     );
//   }
// }
