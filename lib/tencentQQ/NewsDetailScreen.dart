import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import './NewsModel.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsModel newsItem;
  const NewsDetailScreen({Key? key, required this.newsItem}) : super(key: key);

  Future<void> _handleURLTap(BuildContext context) async {
    if (newsItem.url.isEmpty) {
      _showErrorMessage(context, '链接为空');
      return;
    }

    final Uri? uri = Uri.tryParse(newsItem.url);
    if (uri == null) {
      _showErrorMessage(context, '无效的链接格式');
      return;
    }

    try {
      final bool canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        _showErrorMessage(context, '无法打开此链接');
        return;
      }

      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );

      if (!launched && context.mounted) {
        _showErrorMessage(context, '打开链接失败');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorMessage(context, '打开链接出错: ${e.toString()}');
      }
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(newsItem.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => _handleURLTap(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (newsItem.picUrl.isNotEmpty)
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 300),
                child: Image.network(
                  newsItem.picUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, size: 100),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16.0),
            Text(
              newsItem.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '来源: ${newsItem.source} | ${newsItem.ctime}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 16.0),
            Text(
              newsItem.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (newsItem.url.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              InkWell(
                onTap: () => _handleURLTap(context),
                child: Text(
                  '查看原文',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}