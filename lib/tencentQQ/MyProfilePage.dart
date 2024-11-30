import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ChangePasswordPage.dart';
import '../DataBase/LoginDataBase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'Login.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  String weather = '加载中...';
  String temperature = '11';
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _nickname = '加载中...';
  String _avatarPath = 'images/qqAvatar.png';
  String _signature = '被满课压榨中'; // 可以添加到数据库中

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    fetchWeather();
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

  fetchWeather() async {
    const String apiKey = 'a8915ad9ff7dd330c69e2413809f0582';
    const String cityCode = '110101';
    final String apiUrl = 'https://restapi.amap.com/v3/weather/weatherInfo?city=$cityCode&key=$apiKey';

    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var weatherInfo = jsonResponse['lives'][0];
        setState(() {
          weather = weatherInfo['weather'];
          temperature = weatherInfo['temperature'];
        });
      } else {
        setState(() {
          weather = ' ';
        });
      }
    } catch (e) {
      setState(() {
        weather = '雾';
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: _avatarPath.startsWith('/')
                        ? FileImage(File(_avatarPath)) as ImageProvider
                        : AssetImage(_avatarPath),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _nickname,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          _signature,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        // 修改个签
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('我的钱包'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              //
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_album),
            title: const Text('我的相册'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              //
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('我的收藏'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              //
            },
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: const Text('我的文件'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              //
            },
          ),
          // 在"我的文件"ListTile下方添加
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('修改密码'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('退出登录'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () async {
              // 清除登录状态
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('currentQQ');
              await prefs.setBool('autoLogin', false);

              // 返回到登录页面
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,  // 清除所有路由历史
              );
            },
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                  //
                },
              ),
              Text('设置' , style: TextStyle(fontSize: 14)),
                ],
              ),
              Column(
                children: [
                  IconButton(
                  icon: const Icon(Icons.brightness_6),
                  onPressed: () {
                  //
                    },
                  ),
                  Text('主题' , style: TextStyle(fontSize: 14)),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.wb_sunny),
                    onPressed: () {
                      //
                    },
                  ),
                  Text('$weather：$temperature℃', style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
