// import 'dart:io';
// import 'package:dhadkan_front/utils/http/http_client.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart' as path;
//
// class AudioMessage {
//   final File audioFile;
//   final String receiverId;
//   final String token;
//
//   AudioMessage({
//     required this.audioFile,
//     required this.receiverId,
//     required this.token,
//   });
//
//   Future<void> uploadAudio(BuildContext context) async {
//     try {
//       final response = await MyHttpHelper.private_multipart_post(
//         '/chat/upload-audio',
//         {'audio': [audioFile]},
//         token,
//         {'receiver_id': receiverId},
//       );
//
//       if (response['success'] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Audio uploaded successfully!")),
//         );
//       } else {
//         throw Exception("Upload failed");
//       }
//     } catch (e) {
//       print("Audio upload error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to upload audio")),
//       );
//     }
//   }
// }
