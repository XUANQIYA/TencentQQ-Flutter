import 'package:flutter/material.dart';
import 'ContactsPage.dart';

class ChatPage extends StatefulWidget {
  final ContactData contact;

  const ChatPage({Key? key, required this.contact}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}
//消息气泡
class ChatMessage {
  final String text;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.timestamp});
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final String text = _controller.text;
    if (text.isEmpty) return;
//消息添加到列表里并清空输入框
    setState(() {
      messages.add(ChatMessage(
        text: text,
        timestamp: DateTime.now(),
      ));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact.name),//左上联系人昵称
        leading: IconButton(
          icon: Icon(Icons.arrow_back),//pop
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,//气泡靠右
                          children: [
                            Text(
                              message.text,
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 4),//每个气泡间距
                            Text(
                              "${message.timestamp.hour}:${message.timestamp.minute}",
                              style: TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CircleAvatar(
                      backgroundImage: AssetImage('images/qqAvatar.png'), // 使用自己的头像
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(//文本输入框
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '输入消息...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),//圆角
                      ),
                    ),
                    onChanged: (text) {//文本变化时刷新页面UI就变化
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send,
                      color: _controller.text.isEmpty ? Colors.grey : Colors.blue),
                  onPressed: _controller.text.isEmpty ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


