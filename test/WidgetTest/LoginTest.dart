import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/tencentQQ/Login.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('登录界面测试', () {
    testWidgets('登录界面基本UI测试', (WidgetTester tester) async {
      // 构建应用
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 1344,
            height: 2992,
            child: SingleChildScrollView( // 添加这一层
              child: LoginPage(),
            ),
          ),
        ),
      );
      await tester.pump();

      // 验证基本UI元素
      expect(find.byType(TextField), findsNWidgets(2)); // 用户名和密码输入框
      expect(find.byType(ElevatedButton), findsOneWidget); // 登录按钮
      expect(find.byType(Checkbox), findsWidgets); // 复选框

      // 验证文本元素
      expect(find.text('记住密码'), findsOneWidget);
      expect(find.text('自动登录'), findsOneWidget);
    });

    testWidgets('输入验证测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 800,
            child: LoginPage(),
          ),
        ),
      );

      // 点击登录按钮测试空输入
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 等待SnackBar显示
      expect(find.text('请输入账号和密码'), findsOneWidget);

      // 测试无效QQ号
      await tester.enterText(find.byType(TextField).first, 'invalid');
      await tester.enterText(find.byType(TextField).last, 'password');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('请输入正确的QQ号格式'), findsOneWidget);
    });

    testWidgets('记住密码功能测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 800,
            child: LoginPage(),
          ),
        ),
      );

      // 找到记住密码复选框并点击
      final checkboxFinder = find.byType(Checkbox).first;
      await tester.tap(checkboxFinder);
      await tester.pump();

      // 验证复选框状态
      final checkbox = tester.widget<Checkbox>(checkboxFinder);
      expect(checkbox.value, isTrue);
    });

    testWidgets('密码可见性测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 800,
            child: LoginPage(),
          ),
        ),
      );

      // 输入密码
      final passwordField = find.byType(TextField).last;
      await tester.enterText(passwordField, 'test123');
      await tester.pump();

      // 找到密码输入框
      final textField = tester.widget<TextField>(passwordField);
      expect(textField.obscureText, isTrue); // 初始状态应该是隐藏的

      // 点击显示密码按钮
      final visibilityIconButton = find.byIcon(Icons.visibility);
      if (visibilityIconButton.evaluate().isNotEmpty) {
        await tester.tap(visibilityIconButton);
        await tester.pump();

        final updatedTextField = tester.widget<TextField>(passwordField);
        expect(updatedTextField.obscureText, isFalse);
      }
    });
  });

  tearDown(() {
    SharedPreferences.setMockInitialValues({});
  });
}