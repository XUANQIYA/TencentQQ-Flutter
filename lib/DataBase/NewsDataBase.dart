import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../tencentQQ/NewsModel.dart';

class NewsDatabase {
  static final NewsDatabase _instance = NewsDatabase._internal();
  static Database? _database;

  factory NewsDatabase() => _instance;

  NewsDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'news_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }
//建表
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE news (
        id TEXT PRIMARY KEY,
        ctime TEXT,
        title TEXT,
        description TEXT,
        source TEXT,
        picUrl TEXT,
        url TEXT,
        local_image_path TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }
//图片下载
  Future<String?> _downloadAndSaveImage(String imageUrl, String newsId) async {
    if (imageUrl.isEmpty) return null;

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String imagesDir = '${appDir.path}/news_images';
        await Directory(imagesDir).create(recursive: true);

        final String imagePath = '$imagesDir/${newsId}.jpg';
        File imageFile = File(imagePath);
        await imageFile.writeAsBytes(response.bodyBytes);
        return imagePath;
      }
    } catch (e) {
      print('图片下载失败: $e');
    }
    return null;
  }
//保存新闻，插入数据
  Future<void> saveNewsList(List<NewsModel> newsList) async {
    final db = await database;
    final batch = db.batch();

    for (var news in newsList) {
      String? localImagePath;
      if (news.picUrl.isNotEmpty) {
        localImagePath = await _downloadAndSaveImage(news.picUrl, news.id);
      }

      Map<String, dynamic> newsMap = {
        'id': news.id,
        'ctime': news.ctime,
        'title': news.title,
        'description': news.description,
        'source': news.source,
        'picUrl': news.picUrl,
        'url': news.url,
        'local_image_path': localImagePath
      };

      batch.insert('news', newsMap,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }
//本地新闻获取
  Future<List<NewsModel>> getLocalNews() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('news',
        orderBy: 'ctime DESC');

    return maps.map((map) {
      return NewsModel(
        id: map['id'],
        ctime: map['ctime'],
        title: map['title'],
        description: map['description'],
        source: map['source'],
        picUrl: map['picUrl'],
        url: map['url'],
      );
    }).toList();
  }
//清理旧的缓存
  Future<void> cleanOldNews() async {
    final db = await database;
    //7天
    final DateTime threshold = DateTime.now().subtract(Duration(days: 7));

    final List<Map<String, dynamic>> oldNews = await db.query(
        'news',
        where: "ctime < ?",
        whereArgs: [threshold.toIso8601String()]
    );

    for (var news in oldNews) {
      final String? localImagePath = news['local_image_path'];
      if (localImagePath != null) {
        try {
          final file = File(localImagePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('删除旧图片失败: $e');
        }
      }
    }

    await db.delete(
        'news',
        where: "ctime < ?",
        whereArgs: [threshold.toIso8601String()]
    );
  }

  Future<String?> getLocalImagePath(String newsId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
        'news',
        columns: ['local_image_path'],
        where: 'id = ?',
        whereArgs: [newsId]
    );

    if (result.isNotEmpty) {
      return result.first['local_image_path'];
    }
    return null;
  }

  Future<void> clearAllNews() async {
    final db = await database;

    // 删除所有图片文件
    final List<Map<String, dynamic>> news = await db.query('news');
    for (var item in news) {
      final String? localImagePath = item['local_image_path'];
      if (localImagePath != null) {
        try {
          final file = File(localImagePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('删除图片失败: $e');
        }
      }
    }

    // 清空新闻表
    await db.delete('news');
  }

  Future<int> getDatabaseSize() async {
    try {
      String path = join(await getDatabasesPath(), 'news_database.db');
      File dbFile = File(path);
      if (await dbFile.exists()) {
        return await dbFile.length();
      }
    } catch (e) {
      print('获取数据库大小失败: $e');
    }
    return 0;
  }

  Future<int> getImageCacheSize() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = '${appDir.path}/news_images';
      Directory directory = Directory(imagesDir);

      if (await directory.exists()) {
        int total = 0;
        await for (var entity in directory.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            total += await entity.length();
          }
        }
        return total;
      }
    } catch (e) {
      print('获取图片缓存大小失败: $e');
    }
    return 0;
  }
}