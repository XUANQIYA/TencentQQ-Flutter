import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
//设置只有一个数据库
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
//存储数据库的路径与版本设置
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'qq_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }
//建表
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        qq_number TEXT PRIMARY KEY,
        password TEXT NOT NULL,
        nickname TEXT NOT NULL,
        avatar_path TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }
//注册检测
  Future<bool> isQQNumberExists(String qqNumber) async {
    final db = await database;
    var result = await db.query(
      'users',
      where: 'qq_number = ?',
      whereArgs: [qqNumber],
    );
    return result.isNotEmpty;
  }
//新用户注册
  Future<bool> registerUser(String qqNumber, String password, String nickname,
      String? avatarPath) async {
    try {
      final db = await database;
      await db.insert(
        'users',
        {
          'qq_number': qqNumber,
          'password': password,
          'nickname': nickname,
          'avatar_path': avatarPath,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
//登录验证
  Future<bool> validateUser(String qqNumber, String password) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'qq_number = ? AND password = ?',
      whereArgs: [qqNumber, password],
    );

    return results.isNotEmpty;
  }
//信息获取
  Future<Map<String, dynamic>?> getUserInfo(String qqNumber) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'qq_number = ?',
      whereArgs: [qqNumber],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
//修改密码
  Future<bool> updatePassword(String qqNumber, String newPassword) async {
    try {
      final db = await database;
      int count = await db.update(
        'users',
        {'password': newPassword},
        where: 'qq_number = ?',
        whereArgs: [qqNumber],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

}