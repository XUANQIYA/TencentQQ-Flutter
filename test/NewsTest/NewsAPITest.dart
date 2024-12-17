import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../lib/tencentQQ/NewsModel.dart';
import 'dart:convert';

// 生成 Mock HTTP client
@GenerateMocks([http.Client])
import 'NewsAPITest.mocks.dart';
void main() {
  group('新闻API测试', () {
    late MockClient mockClient;
    final String apiUrl = 'https://apis.tianapi.com/generalnews/index?key=ae3a2852ddbfc4321761e6da0880742f';

    setUp(() {
      mockClient = MockClient();
    });

    test('成功获取新闻列表', () async {
      // 准备模拟的响应数据
      final mockResponse = {
        "code": 200,
        "msg": "success",
        "result": {
          "curpage": 1,
          "allnum": 10,
          "newslist": [
            {
              "id": "9de7eb6df1d70ae94eb794f76ec9bb6f",
              "ctime": "2024-12-05 22:00:09",
              "title": "新闻标题",
              "description": "据央视新闻报道，今年9月，朱雀三号火箭完成10公里级垂直起降飞行试验。朱雀三号预计明年下半年发射，有望成为中国第一枚投入运营的可回收运载火箭。蓝箭航天创始人张昌武在《鲁健访谈》中介绍，2030年前后能实现两级重复使用火箭的工程落地。",
              "source": "IT家科学探索",
              "picUrl": "https://img.ithome.com/newsuploadfiles/thumbnail/2024/12/815659_240.jpg?x-bce-process=image/format,f_auto",
              "url": "https://www.ithome.com/0/815/659.htm"
            }
          ]
        }
      };

      // 设置mock响应，使用 UTF-8 编码
      when(mockClient.get(Uri.parse(apiUrl)))
          .thenAnswer((_) async => http.Response(
          utf8.decode(utf8.encode(json.encode(mockResponse))),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'}
      ));

      // 执行API调用
      final response = await mockClient.get(Uri.parse(apiUrl));
      final jsonResponse = json.decode(response.body);

      // 验证响应
      expect(response.statusCode, 200);
      expect(jsonResponse['code'], 200);
      expect(jsonResponse['result']['newslist'].length, 1);

      // 验证新闻数据结构
      final newsItem = jsonResponse['result']['newslist'][0];
      expect(newsItem['title'], '新闻标题');
      expect(newsItem['source'], 'IT家科学探索');
    });

    test('API请求失败测试', () async {
      // 模拟网络错误
      when(mockClient.get(Uri.parse(apiUrl)))
          .thenThrow(Exception('网络连接失败'));

      // 验证异常处理
      expect(() async => await mockClient.get(Uri.parse(apiUrl)),
          throwsException);
    });

    test('API返回错误状态码测试', () async {
      // 模拟服务器错误响应
      when(mockClient.get(Uri.parse(apiUrl)))
          .thenAnswer((_) async => http.Response('{"error": "ServeError!"}', 500));

      final response = await mockClient.get(Uri.parse(apiUrl));
      expect(response.statusCode, 500);
    });

    test('新闻数据模型转换测试', () async {
      final mockNewsData = {
        "id": "test_id",
        "ctime": "2024-12-05 20:20:00",
        "title": "测试新闻标题",
        "description": "测试描述",
        "source": "测试来源",
        "picUrl": "https://example.com/test.jpg",
        "url": "https://example.com/news"
      };

      final newsModel = NewsModel.fromJson(mockNewsData);

      expect(newsModel.id, 'test_id');
      expect(newsModel.title, '测试新闻标题');
      expect(newsModel.source, '测试来源');
      expect(newsModel.picUrl, 'https://example.com/test.jpg');
    });

    test('空数据处理测试', () async {
      final mockResponse = {
        "code": 200,
        "msg": "success",
        "result": {
          "curpage": 1,
          "allnum": 0,
          "newslist": []
        }
      };

      when(mockClient.get(Uri.parse(apiUrl)))
          .thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));

      final response = await mockClient.get(Uri.parse(apiUrl));
      final jsonResponse = json.decode(response.body);

      expect(jsonResponse['result']['newslist'], isEmpty);
    });
  });
}