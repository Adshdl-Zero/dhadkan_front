// import 'package:flutter/material.dart';

// class PatientBox extends StatelessWidget {
//   final String imageUrl;
//   final String name;
//   final String edd;
//   final String doctorName;
//   final String doctorMobile;
//   final VoidCallback onTap;

//   const PatientBox({
//     super.key,
//     required this.imageUrl,
//     required this.name,
//     required this.edd,
//     required this.doctorName,
//     required this.doctorMobile,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         margin: EdgeInsets.symmetric(vertical: 8),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         elevation: 3,
//         child: Padding(
//           padding: EdgeInsets.all(12),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Patient Image
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(
//                   imageUrl,
//                   width: 80,
//                   height: 80,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) =>
//                       Icon(Icons.person, size: 80, color: Colors.grey),
//                 ),
//               ),
//               SizedBox(width: 16),

//               // Patient Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     Text("EDD: $edd", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
//                     Text("Doctor: $doctorName", style: TextStyle(fontSize: 14, color: Colors.black)),
//                     Text("Contact: $doctorMobile", style: TextStyle(fontSize: 14, color: Colors.blue)),
//                   ],
//                 ),
//               ),

//               // Arrow Icon
//               Icon(Icons.arrow_forward_ios, color: Colors.grey),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
