import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../DataBase/LoginDataBase.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  bool _isAgreed = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isPasswordValid(String password) {
    // 检查密码长度是否为8位
    if (password.length != 8) return false;

    // 检查是否同时包含数字和字母
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasLetter = password.contains(RegExp(r'[a-zA-Z]'));

    return hasDigit && hasLetter;
  }

  final Color elegantBlue = Color(0xFF2E5B9A);

  Future<void> _selectImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // 复制图片到应用程序目录
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
        final String localPath = path.join(appDir.path, fileName);

        await File(image.path).copy(localPath);

        setState(() {
          _selectedImagePath = localPath;
        });
      }
    } catch (e) {
      _showSnackBar('选择图片失败');
    }
  }

  Future<void> _register() async {
    String account = _accountController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String nickname = _nicknameController.text;

    // 基本验证
    if (account.isEmpty || password.isEmpty || confirmPassword.isEmpty || nickname.isEmpty) {
      _showSnackBar('请填写所有信息');
      return;
    }

    // 密码格式验证
    if (!_isPasswordValid(password)) {
      _showSnackBar('密码必须是8位数字与字母的组合');
      return;
    }

    if (!_isAgreed) {
      _showSnackBar('请同意用户协议与隐私政策');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('两次输入的密码不一致');
      return;
    }

    // QQ号格式验证
    if (!RegExp(r'^[1-9]\d{4,10}$').hasMatch(account)) {
      _showSnackBar('请输入5-11位的有效QQ号');
      return;
    }

    //检查QQ号是否已存在
    bool exists = await _dbHelper.isQQNumberExists(account);
    if (exists) {
      _showSnackBar('该QQ号已被注册');
      return;
    }

    //注册用户
    bool success = await _dbHelper.registerUser(
        account,
        password,
        nickname,
        _selectedImagePath
    );

    if (success) {
      _showSnackBar('注册成功');
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } else {
      _showSnackBar('注册失败，请重试');
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '登录',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black54,
          ),
        ),
      ),
      body: Container(
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: _selectImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              border: Border.all(
                                color: elegantBlue.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: _selectedImagePath != null
                                ? ClipOval(
                              child: Image.file(
                                File(_selectedImagePath!),
                                fit: BoxFit.cover,
                              ),
                            )
                                : Icon(
                              Icons.add_a_photo,
                              color: elegantBlue,
                              size: 40,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '点击选择头像',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 32),
                        _buildTextField(
                          controller: _accountController,
                          hint: '请输入QQ号（5-11位数字）',
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.number,  // 新增数字键盘类型
                        ),
                        SizedBox(height: 16),

                        // 新增昵称输入框
                        _buildTextField(
                          controller: _nicknameController,
                          hint: '请输入昵称',
                          icon: Icons.face_outlined,
                        ),
                        SizedBox(height: 16),

                        // 密码输入框保持不变
                        _buildTextField(
                          controller: _passwordController,
                          hint: '请设置密码',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible,
                          onTogglePassword: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        SizedBox(height: 16),

                        // 确认密码输入框
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hint: '请确认密码',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          isPasswordVisible: _isConfirmPasswordVisible,
                          onTogglePassword: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                        SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _register,
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
                        SizedBox(height: 24),
                        _buildAgreementRow(),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).padding.bottom + 20,
                color: Color(0xFFEDF4FF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
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
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 16),
        // 添加密码输入提示
        onChanged: isPassword ? (value) {
          if (value.length > 8) {
            controller.text = value.substring(0, 8);
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: 8),
            );
          }
        } : null,
        decoration: InputDecoration(
          hintText: isPassword ? '$hint (8位数字与字母组合)' : hint,
          counterText: "",
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: isPassword ? 14 : 16),
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
        Flexible(
          child: Text.rich(
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
        ),
      ],
    );
  }
}