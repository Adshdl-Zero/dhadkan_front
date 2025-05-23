import 'package:dhadkan_front/features/common/Wrapper.dart';
import 'package:dhadkan_front/utils/constants/colors.dart';
import 'package:dhadkan_front/utils/device/device_utility.dart';
import 'package:dhadkan_front/utils/http/http_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatTextBox extends StatefulWidget {
  final String receiver_id;
  final String token;

  const ChatTextBox(
      {super.key, required this.receiver_id, required this.token});

  @override
  State<ChatTextBox> createState() => _ChatTextBoxState();
}

class _ChatTextBoxState extends State<ChatTextBox> {
  final TextEditingController _textController = TextEditingController();

  handleRecord() {}

  handleSend() async {
    try {
      // print(widget.token);
      Map<String, dynamic> response =
          await MyHttpHelper.private_post('/chat/send-text', {
            'receiver_id': widget.receiver_id,
            'text': _textController.text
          }, widget.token);
      print(response);
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text(response['message'])));
      if (response['success'] == 'true'){
        _textController.clear();
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Some error occurred!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MyDeviceUtils.getScreenWidth(context);
    return Wrapper(
      top: 5,
      bottom: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screenWidth * 0.9,
            height: 45,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              //border: Border.all(color: MyColors.primary, width: 0.3),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(children: [
              Container(
                  height: 30,
                  width: 30,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: handleRecord,
                    child: const Icon(
                      Icons.mic,
                      color: MyColors.primary,
                    ),
                  )),
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  ),
                ),
              ),
              IconButton(
                onPressed: handleSend,
                icon: const Icon(Icons.send, color: MyColors.primary),
                padding: EdgeInsets.zero,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
