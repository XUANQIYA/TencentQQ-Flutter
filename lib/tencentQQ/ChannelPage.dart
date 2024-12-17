import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import './NewsModel.dart';
import './NewsDetailScreen.dart';
import '../DataBase/NewsDataBase.dart';

class ChannelPage extends StatefulWidget {
  const ChannelPage({Key? key}) : super(key: key);

  @override
  _ChannelPageState createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  final String apiUrl = 'https://apis.tianapi.com/generalnews/index?key=ae3a2852ddbfc4321761e6da0880742f';
  List<NewsModel> newsList = [];
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  bool _isLoading = false;
  String weather = '加载中...';
  String temperature = '11';
  final NewsDatabase _newsDb = NewsDatabase();

  @override
  void initState() {
    super.initState();
    _loadNews();
    fetchWeather();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    setState(() {
      _showBackToTopButton = _scrollController.offset >= 20;
    });
  }

  Future<void> fetchWeather() async {
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
          weather = '';
        });
      }
    } catch (e) {
      setState(() {
        weather = '';
      });
      print(e);
    }
  }

  Future<void> _loadNews() async {
    // 尝试从本地数据库加载新闻
    final localNews = await _newsDb.getLocalNews();
    if (localNews.isNotEmpty) {
      setState(() {
        newsList = localNews;
      });
    }
    // 然后从网络获取最新新闻
    await fetchNews();
  }
  // 测试
  //   final invalidNewsItem = NewsModel(
  //   id: '92e5f080884dce68cbf751378a779e90',
  //   title: '空测试',
  //   description: '测试新闻项返回本地图片',
  //   source: '测试资源',
  //   ctime: '2024-11-21',
  //   picUrl: 'C:/Users/Tom Wu/Pictures/桌面壁纸/1729389712377.jpg', // 无效 URL
  //   url: 'https://copilot.microsoft.com'
  // );
  // newsList.add(invalidNewsItem);
  Future<void> fetchNews() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['result'] != null &&
            jsonResponse['result']['newslist'] != null) {
          final List<NewsModel> fetchedNews = (jsonResponse['result']['newslist'] as List)
              .map((item) => NewsModel.fromJson(item))
              .toList();

          // 保存到数据库
          await _newsDb.saveNewsList(fetchedNews);

          // 更新UI
          setState(() {
            newsList = fetchedNews;
          });

          // 清理旧新闻
          await _newsDb.cleanOldNews();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取新闻失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

Future<void> _handleRefresh() async {
  imageCache.clear();
  imageCache.clearLiveImages();
  await Future.wait([fetchNews(), fetchWeather()]);
}

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新闻频道'),
        automaticallyImplyLeading: false,
        actions: [
          Row(
            children: [
              Icon(Icons.wb_sunny),
              SizedBox(width: 4),
              Text('$weather：$temperature℃'),
              SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _handleRefresh,
            child: _isLoading && newsList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final newsItem = newsList[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8),
                    title: Text(
                      newsItem.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (newsItem.description.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              newsItem.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            '${newsItem.source} | ${newsItem.ctime}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    leading: newsItem.picUrl.isNotEmpty
                        ? FutureBuilder<String?>(
                      future: _newsDb.getLocalImagePath(newsItem.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          // 使用本地图片
                          return SizedBox(
                            width: 60,
                            height: 60,
                            child: Image.file(
                              File(snapshot.data!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.broken_image),
                            ),
                          );
                        } else {
                          // 使用网络图片
                          return SizedBox(
                            width: 60,
                            height: 60,
                            child: Image.network(
                              newsItem.picUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.broken_image),
                            ),
                          );
                        }
                      },
                    )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NewsDetailScreen(newsItem: newsItem),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (_showBackToTopButton)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: _scrollToTop,
                child: Icon(Icons.arrow_upward),
                mini: true,
              ),
            ),
        ],
      ),
    );
  }
}