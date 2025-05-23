import 'dart:async';

import 'package:dhadkan_front/features/chat/ChatTextBox.dart';
import 'package:dhadkan_front/features/chat/TextMessage.dart';
import 'package:dhadkan_front/features/common/TopBar.dart';
import 'package:dhadkan_front/features/common/Wrapper.dart';
import 'package:dhadkan_front/utils/device/device_utility.dart';
import 'package:dhadkan_front/utils/http/http_client.dart';
import 'package:dhadkan_front/utils/storage/secure_storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../auth/LandingScreen.dart'; // Assuming LandingScreen.dart is in this path

class ConversationScreen extends StatefulWidget {
  final String receiver_id;

  const ConversationScreen({super.key, required this.receiver_id});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  String _token = "";
  List<dynamic> _chats = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _initialize();
    // Poll for new messages every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_token.isNotEmpty) { // Only reload if token is available
        _reloadChat();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  _initialize() async {
    String? token = await SecureStorageService.getData('authToken');
    if (token == null || token.isEmpty) {
      // If token is not found, navigate to LandingScreen and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LandingScreen()), // Ensure LandingScreen is imported
            (route) => false,
      );
    } else {
      setState(() {
        _token = token;
      });
      // Initial load of chat messages
      _reloadChat();
    }
  }

  _reloadChat() async {
    // Ensure token is available before making the API call
    if (_token.isEmpty) return;

    try {
      Map<String, dynamic> response = await MyHttpHelper.private_post(
          '/chat/get-texts', {'receiver_id': widget.receiver_id}, _token);
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _chats = response['data'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Error in loading Texts")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MyDeviceUtils.getScreenWidth(context);
    double paddingWidth = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const TopBar(title: "Chat Screen"), // Title can be customized further if needed
      ),
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
                  reverse: true, // To keep the view at the bottom for new messages
                  padding: EdgeInsets.symmetric(horizontal: paddingWidth),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(height: 10),
                        for (var item in _chats)
                          if (item['message_type'] == 'text')
                            TextMessage(
                              text: item['text']!,
                              mine: item['mine'], // 'mine' flag distinguishes sender
                            )
                      ]))),
          // Display ChatTextBox only if token is available
          if (_token.isNotEmpty)
            ChatTextBox(receiver_id: widget.receiver_id, token: _token)
        ],
      ),
    );
  }
}