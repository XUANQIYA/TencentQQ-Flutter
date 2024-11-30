import 'package:flutter/material.dart';
import '../DataBase/LoginDataBase.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _qqController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
//可见性
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final Color elegantBlue = Color(0xFF2E5B9A);
//验证8位和字母
  bool _isPasswordValid(String password) {
    if (password.length != 8) return false;
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
    return hasDigit && hasLetter;
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

  Future<void> _changePassword() async {
    String qq = _qqController.text;
    String oldPassword = _oldPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // 基本验证
    if (qq.isEmpty || oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('请填写所有信息');
      return;
    }

    // 验证QQ号格式
    if (!RegExp(r'^[1-9]\d{4,10}$').hasMatch(qq)) {
      _showSnackBar('请输入正确的QQ号');
      return;
    }

    // 验证旧密码
    bool isValid = await _dbHelper.validateUser(qq, oldPassword);
    if (!isValid) {
      _showSnackBar('QQ号或原密码错误');
      return;
    }

    // 验证新密码格式
    if (!_isPasswordValid(newPassword)) {
      _showSnackBar('新密码必须是8位数字与字母的组合');
      return;
    }

    // 确认新密码
    if (newPassword != confirmPassword) {
      _showSnackBar('两次输入的新密码不一致');
      return;
    }

    // 不能与原密码相同
    if (oldPassword == newPassword) {
      _showSnackBar('新密码不能与原密码相同');
      return;
    }

    // 更新密码
    bool success = await _dbHelper.updatePassword(qq, newPassword);
    if (success) {
      _showSnackBar('密码修改成功');
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } else {
      _showSnackBar('密码修改失败，请重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '修改密码',
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
              Color(0xFFF8F9FE),  // 更浅的起始色
              Color(0xFFE8EFFD),  // 更浅的结束色
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              _buildTextField(
                controller: _qqController,
                hint: '请输入QQ号',
                icon: Icons.person_outline,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _oldPasswordController,
                hint: '请输入原密码',
                icon: Icons.lock_outline,
                isPassword: true,
                isPasswordVisible: _isOldPasswordVisible,
                onTogglePassword: () {
                  setState(() {
                    _isOldPasswordVisible = !_isOldPasswordVisible;
                  });
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _newPasswordController,
                hint: '请输入新密码',
                icon: Icons.lock_outline,
                isPassword: true,
                isPasswordVisible: _isNewPasswordVisible,
                onTogglePassword: () {
                  setState(() {
                    _isNewPasswordVisible = !_isNewPasswordVisible;
                  });
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _confirmPasswordController,
                hint: '请确认新密码',
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
              Container(
                width: 56,
                height: 56,
                child: ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    backgroundColor: elegantBlue,
                    elevation: 3,
                    shadowColor: elegantBlue.withOpacity(0.5),
                    padding: EdgeInsets.zero,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// 修改输入框样式
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 15,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.grey[400],
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[400],
              size: 22,
            ),
            onPressed: onTogglePassword,
          )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}