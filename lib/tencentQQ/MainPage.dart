import 'package:flutter/material.dart';
import 'MyProfilePage.dart';//个人主页
import 'ChannelPage.dart';//频道
import 'ContactsPage.dart';//联系人
import 'MomentsPage.dart';//动态
import 'MainPageToChatPage.dart'; //聊天界面
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../DataBase/LoginDataBase.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QQ主界面',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),//主页
    );
  }
}
//重写保持更新
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //底部导航栏下标定位
  int _currentIndex = 0;
  final PageController _pageController = PageController();
// 页面列表
  final List<Widget> _pages = [
    MessagesPage(),
    ChannelPage(),
    ContactsPage(),
    MomentsPage(),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: GestureDetector(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _pages,
        ),
      ),
      drawer: const MyProfilePage(),//侧边栏
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            //页面下标更新
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hub),
            label: '新闻',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: '联系人',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '地图',
          ),
        ],
      ),
    );
  }
}

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

//聊天栏定义
class ChatData {
  final String name;
  final String lastMessage;
  final String time;
  final String avatarUrl;

  ChatData(this.name, this.lastMessage, this.time, this.avatarUrl);
}

class ChatListItem extends StatelessWidget {
  final ChatData chat;

  const ChatListItem({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(chat.avatarUrl),
      ),
      title: Text(chat.name),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        chat.time,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}

class _MessagesPageState extends State<MessagesPage> {

  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _nickname = '加载中...';
  String _avatarPath = 'images/qqAvatar.png';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? currentQQ = prefs.getString('currentQQ');

    if (currentQQ != null) {
      final userInfo = await _dbHelper.getUserInfo(currentQQ);
      if (userInfo != null) {
        setState(() {
          _nickname = userInfo['nickname'] ?? '未设置昵称';
          _avatarPath = userInfo['avatar_path'] ?? 'images/qqAvatar.png';
        });
      }
    }
  }

  final List<ChatData> chats = [
    ChatData('flutter大佬小谭', '我天天满课，就没去', '下午3:36', 'images/loginBackgroundPicture.png'),
    ChatData('编程张三', '明天有个双选会去不去', '下午4:00', 'images/qqIcon.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: _avatarPath.startsWith('/')
                  ? FileImage(File(_avatarPath)) as ImageProvider
                  : AssetImage(_avatarPath),
            ),
          ),
        ),
        title: GestureDetector(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nickname,
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.add, color: Colors.black),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Text('创建群聊'),
              ),
              const PopupMenuItem(
                value: 2,
                child: Text('加好友/群'),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(contact: chats[index]),
                ),
              );
            },
            child: ChatListItem(chat: chats[index]),
          );
        },
      ),
    );
  }
}

