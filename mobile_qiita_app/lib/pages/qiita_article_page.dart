import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mobile_qiita_app/services/article.dart';
import 'package:mobile_qiita_app/constants.dart';

class QiitaArticlePage extends StatefulWidget {
  const QiitaArticlePage({ required this.article, Key? key}) : super(key: key);

  final Article article;

  @override
  _QiitaArticlePageState createState() => _QiitaArticlePageState();
}

class _QiitaArticlePageState extends State<QiitaArticlePage> {
  double _webViewHeight = 0;
  late WebViewController _webViewController;

  // WebViewの高さを求めて_webViewHeightに代入
  Future<void> _calculateWebViewHeight() async {
    double newHeight = double.parse(
      await _webViewController
          .evaluateJavascript("document.documentElement.scrollHeight;"),
    );
    setState(() {
      _webViewHeight = newHeight;
    });
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
              color: const Color(0xF7F7F7FF),
            ),
            height: 59.0,
            child: Center(
              child: const Text(
                'Article',
                style: Constants.headerTextStyle,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                height: _webViewHeight,
                child: WebView(
                  initialUrl: widget.article.url,
                  javascriptMode: JavascriptMode.unrestricted,
                  onPageFinished: (String url) => _calculateWebViewHeight(),
                  onWebViewCreated: (controller) async {
                    _webViewController = controller;
                  },
                  onWebResourceError: (error) {
                    print(error);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
