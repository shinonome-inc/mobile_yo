import 'package:flutter/material.dart';
import 'package:mobile_qiita_app/common/variables.dart';
import 'package:mobile_qiita_app/components/app_bar_component.dart';
import 'package:mobile_qiita_app/extension/pagination_scroll.dart';
import 'package:mobile_qiita_app/models/article.dart';
import 'package:mobile_qiita_app/models/user.dart';
import 'package:mobile_qiita_app/services/qiita_client.dart';
import 'package:mobile_qiita_app/views/error_views.dart';
import 'package:mobile_qiita_app/views/user_page_view.dart';

class UserPage extends StatefulWidget {
  const UserPage({
    required this.user,
    required this.appBarTitle,
    required this.useBackButton,
    Key? key,
  }) : super(key: key);

  final User user;
  final String appBarTitle;
  final bool useBackButton;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final ScrollController _scrollController = ScrollController();
  late Future<List<Article>> _futureArticles;
  late List<Article> _fetchedArticles;
  int _currentPageNumber = 1;
  final String _searchWord = '';
  final String _tagId = '';
  bool _isNetworkError = false;
  bool _isLoading = false;

  // 再読み込み
  Future<void> _reload() async {
    setState(() {
      _futureArticles = QiitaClient.fetchArticle(
          _currentPageNumber, _searchWord, _tagId, widget.user.id);
    });
  }

  // 記事を追加読み込み
  Future<void> _readAdditionally() async {
    if (!_isLoading) {
      _isLoading = true;
      _currentPageNumber++;
      setState(() {
        _futureArticles = QiitaClient.fetchArticle(
            _currentPageNumber, _searchWord, _tagId, widget.user.id);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (Variables.isAuthenticated) {
      _futureArticles = QiitaClient.fetchArticle(
          _currentPageNumber, _searchWord, _tagId, widget.user.id);
    }
    _scrollController.addListener(() {
      if (_scrollController.isBottom) {
        _readAdditionally();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
          title: widget.appBarTitle, useBackButton: widget.useBackButton),
      body: SafeArea(
        child: FutureBuilder(
          future: _futureArticles,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            Widget child = Container();
            bool hasData = snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done;
            bool hasError = snapshot.hasError &&
                snapshot.connectionState == ConnectionState.done;
            bool isWaiting = (_isNetworkError || _currentPageNumber == 1) &&
                snapshot.connectionState == ConnectionState.waiting;

            if (_currentPageNumber != 1) {
              child = UserPageView(
                onTapReload: _reload,
                user: widget.user,
                articles: _fetchedArticles,
                scrollController: _scrollController,
              );
            }

            if (hasData && _currentPageNumber == 1) {
              _isLoading = false;
              _isNetworkError = false;
              _fetchedArticles = snapshot.data;
              child = UserPageView(
                onTapReload: _reload,
                user: widget.user,
                articles: _fetchedArticles,
                scrollController: _scrollController,
              );
            } else if (hasData) {
              _isLoading = false;
              _isNetworkError = false;
              _fetchedArticles.addAll(snapshot.data);
            } else if (hasError) {
              _isNetworkError = true;
              child = ErrorView.networkErrorView(_reload);
            } else if (isWaiting) {
              child = CircularProgressIndicator();
            }

            return Container(
              child: Center(
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}
