import 'package:flutter/material.dart';
import 'ContactsPageToChatPage.dart'; // 导入 ChatPage

class ContactsPage extends StatelessWidget {
  final List<ContactData> contacts = [
    ContactData(
      'flutter大佬小谭', '每天进步一点点', '在线', 'images/loginBackgroundPicture.png',
    ),
    ContactData(
      '编程张三', '代码改变世界', '离线', 'images/qqIcon.png',
    ),
    ContactData(
      '编程张四', '代码改变世界', '离线', 'images/qqIcon.png',
    ),
    ContactData(
      '编程张五', '代码改变世界', '离线', 'images/qqIcon.png',
    ),
    ContactData(
      '编程张6', '代码改变世界', '在线', 'images/qqIcon.png',
    ),
    ContactData(
      '编程张七', '代码改变世界', '离线', 'images/qqIcon.png',
    ),
    ContactData(
      '编程张拔', '代码改变世界', '离线', 'images/qqIcon.png',
    ),
    ContactData(
      '编程张舅', '代码改变世界', '在线', 'images/qqIcon.png',
    ),
  ];

  ContactsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('联系人'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '搜索',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Text('新朋友',
              style: TextStyle(fontSize: 16.0),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 跳转逻辑
            },
          ),
          ListTile(
            leading: Text('群通知',
            style: TextStyle(fontSize: 16.0),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 跳转逻辑
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(contact: contacts[index]),
                      ),
                    );
                  },
                  child: ContactListItem(contact: contacts[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ContactData {
  final String name;
  final String signature;
  final String status;
  final String avatarUrl;

  ContactData(this.name, this.signature, this.status, this.avatarUrl);
}

class ContactListItem extends StatelessWidget {
  final ContactData contact;

  const ContactListItem({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(contact.avatarUrl),
      ),
      title: Text(contact.name),
      subtitle: Text(contact.signature),
      trailing: Text(
        contact.status,
        style: TextStyle(
          color: contact.status == '在线' ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}
