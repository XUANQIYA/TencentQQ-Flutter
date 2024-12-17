import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './RegisterPage.dart';
import '../DataBase/LoginDataBase.dart';
import 'MainPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '登录界面',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isAgreed = true;
  bool _isPasswordVisible = false;
  bool _rememberPassword = false;
  bool _autoLogin = false;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      //记住密码状态
      _rememberPassword = prefs.getBool('rememberPassword') ?? false;
      _autoLogin = prefs.getBool('autoLogin') ?? false;

      if (_rememberPassword) {
        _usernameController.text = prefs.getString('username') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      }
      //自动登录
      if (_autoLogin && _usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _login();
        });
      }
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    //保存状态
    await prefs.setBool('rememberPassword', _rememberPassword);
    await prefs.setBool('autoLogin', _autoLogin);
    //记住则保存
    if (_rememberPassword) {
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('password', _passwordController.text);
    } else {
      //否则清空
      await prefs.remove('username');
      await prefs.remove('password');
      await prefs.setBool('autoLogin', false);
      _autoLogin = false;
    }
  }

  // 界面蓝
  final Color elegantBlue = Color(0xFF2E5B9A);

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('请输入账号和密码');
      return;
    }

    if (!_isAgreed) {
      _showSnackBar('请同意用户协议与隐私政策');
      return;
    }

    // 验证QQ号格式
    if (!RegExp(r'^[1-9]\d{4,10}$').hasMatch(username)) {
      _showSnackBar('请输入正确的QQ号格式');
      return;
    }

    // 验证
    bool isValid = await _dbHelper.validateUser(username, password);

    if (isValid) {
      await _saveSettings();

      // 保存当前登录的QQ号
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentQQ', username);


      Navigator.pushReplacement( // 替换当前页面
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } else {
      _showSnackBar('账号或密码不正确');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
        backgroundColor: elegantBlue.withOpacity(0.9),
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    body: SingleChildScrollView( // 添加滚动视图
    child: Container(
    height: MediaQuery.of(context).size.height,
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
    Colors.white,
    Color(0xFFF5F9FF),
    Color(0xFFEDF4FF),
    ],
    ),
    ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(height: 35.0),
                // QQ图标和文字
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        child: Image.asset('images/qqIcon.png'),
                      ),
                      Container(
                        width: 130,
                        height: 75,
                        child: Image.asset('images/qqFont.png'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 34.0),
                _buildTextField(
                  controller: _usernameController,
                  hint: '请输入账号',
                  icon: Icons.person_outline,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  hint: '请输入密码',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  onTogglePassword: _togglePasswordVisibility,
                ),
                // 在密码输入框后添加
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberPassword,
                            onChanged: (value) {
                              setState(() {
                                _rememberPassword = value ?? false;
                                if (!_rememberPassword) _autoLogin = false;
                                _saveSettings();
                              });
                            },
                          ),
                          Text('记住密码'),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _autoLogin,
                            onChanged: (value) {
                              setState(() {
                                if (value ?? false) _rememberPassword = true;
                                _autoLogin = value ?? false;
                                _saveSettings();
                              });
                            },
                          ),
                          Text('自动登录'),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // 高级蓝色登录按钮
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(25),
                    backgroundColor: elegantBlue,
                    elevation: 3,
                    shadowColor: elegantBlue.withOpacity(0.5),
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                _buildAgreementRow(),
                Spacer(),
                _buildBottomActions(),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      )
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: elegantBlue.withOpacity(0.7)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: elegantBlue.withOpacity(0.7),
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildAgreementRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _isAgreed,
            onChanged: (value) => setState(() => _isAgreed = value ?? false),
            activeColor: elegantBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(width: 8),
        Text.rich(
          TextSpan(
            text: '已阅读并同意',
            style: TextStyle(fontSize: 12, color: Colors.black54),
            children: [
              TextSpan(
                text: '服务协议',
                style: TextStyle(
                  color: elegantBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
              TextSpan(text: '和'),
              TextSpan(
                text: 'QQ隐私保护指引',
                style: TextStyle(
                  color: elegantBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

Widget _buildBottomActions() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            // 手机号登录逻辑
          },
          child: _buildBottomAction(Icons.phone, '手机号登录'),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterPage()),
            );
          },
          child: _buildBottomAction(Icons.person_add, '新用户注册'),
        ),
        GestureDetector(
          onTap: () {
            // 更多选项逻辑
          },
          child: _buildBottomAction(Icons.more_horiz, '更多选项'),
        ),
      ],
    ),
  );
}

  Widget _buildBottomAction(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: elegantBlue.withOpacity(0.7)),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: elegantBlue.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}