import 'package:flutter_test/flutter_test.dart';
import '../../lib/tencentQQ/NewsModel.dart';

void main() {
  group('NewsModel Tests', () {
    test('创建NewsModel实例测试', () {
      final news = NewsModel(
          id: '1',
          ctime: '2024-01-01',
          title: '测试新闻',
          description: '这是一条测试新闻',
          source: '测试来源',
          picUrl: 'https://example.com/image.jpg',
          url: 'https://example.com/news/1'
      );

      expect(news.id, '1');
      expect(news.ctime, '2024-01-01');
      expect(news.title, '测试新闻');
      expect(news.description, '这是一条测试新闻');
      expect(news.source, '测试来源');
      expect(news.picUrl, 'https://example.com/image.jpg');
      expect(news.url, 'https://example.com/news/1');
    });

    group('fromJson Tests', () {
      test('正常JSON数据转换测试', () {
        final Map<String, dynamic> json = {
          'id': '1',
          'ctime': '2024-01-01',
          'title': '测试新闻',
          'description': '这是一条测试新闻',
          'source': '测试来源',
          'picUrl': 'https://example.com/image.jpg',
          'url': 'https://example.com/news/1'
        };

        final news = NewsModel.fromJson(json);

        expect(news.id, '1');
        expect(news.ctime, '2024-01-01');
        expect(news.title, '测试新闻');
        expect(news.description, '这是一条测试新闻');
        expect(news.source, '测试来源');
        expect(news.picUrl, 'https://example.com/image.jpg');
        expect(news.url, 'https://example.com/news/1');
      });

      test('缺失字段JSON数据转换测试', () {
        final Map<String, dynamic> json = {
          'id': '1',
          'title': '测试新闻'
          // 其他字段缺失
        };

        final news = NewsModel.fromJson(json);

        expect(news.id, '1');
        expect(news.ctime, '');
        expect(news.title, '测试新闻');
        expect(news.description, '');
        expect(news.source, '');
        expect(news.picUrl, '');
        expect(news.url, '');
      });

      test('空JSON数据转换测试', () {
        final Map<String, dynamic> json = {};

        final news = NewsModel.fromJson(json);

        expect(news.id, '');
        expect(news.ctime, '');
        expect(news.title, '');
        expect(news.description, '');
        expect(news.source, '');
        expect(news.picUrl, '');
        expect(news.url, '');
      });

      test('JSON数据包含null值转换测试', () {
        final Map<String, dynamic> json = {
          'id': null,
          'ctime': null,
          'title': null,
          'description': null,
          'source': null,
          'picUrl': null,
          'url': null
        };

        final news = NewsModel.fromJson(json);

        expect(news.id, '');
        expect(news.ctime, '');
        expect(news.title, '');
        expect(news.description, '');
        expect(news.source, '');
        expect(news.picUrl, '');
        expect(news.url, '');
      });
    });
  });
}