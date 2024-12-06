import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../gameServerService.dart';

class ChatPopup extends StatefulWidget {
  const ChatPopup({Key? key}) : super(key: key);

  @override
  _ChatPopupState createState() => _ChatPopupState();
}

class _ChatPopupState extends State<ChatPopup> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = []; // 채팅 메시지 저장

  @override
  void initState() {
    super.initState();

    // Listen to server notifications
    final serverService = Provider.of<GameServerService>(context, listen: false);
    serverService.notifyStream.listen((notifyMessage) {
      if (notifyMessage.notifyType == "CHAT") {
        setState(() {
          _messages.add("${notifyMessage.sender}: ${notifyMessage.notifyBody}");
        });
      }
    }, onError: (error) {
      print("Error in notify stream: $error");
    });
  }

  void _sendMessage() async {
    final serverService = Provider.of<GameServerService>(context, listen: false);
    final message = _messageController.text.trim();

    if (message.isNotEmpty) {
      try {
        await serverService.sendChat(message);
        setState(() {
          _messages.add("나: $message"); // Add the message to the UI immediately
        });
        _messageController.clear();
      } catch (e) {
        print("Failed to send message: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send message. Try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.redAccent, width: 2),
        ),
        child: Column(
          children: [
            const Text(
              '채팅방',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.redAccent),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text(
                      _messages[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      hintText: '메시지 입력...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.redAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
