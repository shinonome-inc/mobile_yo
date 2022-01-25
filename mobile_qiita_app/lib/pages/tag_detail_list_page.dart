import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile_qiita_app/constants.dart';
import 'package:mobile_qiita_app/extension/pagination_scroll.dart';
import 'package:mobile_qiita_app/models/article.dart';
import 'package:mobile_qiita_app/models/tag.dart';
import 'package:mobile_qiita_app/services/client.dart';
import 'package:mobile_qiita_app/views/error_views.dart';
import 'package:mobile_qiita_app/views/scrollable_modal_bottom_sheet.dart';

class TagDetailListPage extends StatefulWidget {
  const TagDetailListPage({required this.tag, Key? key}) : super(key: key);

  final Tag tag;

  @override
  _TagDetailListPageState createState() => _TagDetailListPageState();
}

class _TagDetailListPageState extends State<TagDetailListPage> {
  final ScrollController _scrollController = ScrollController();
  late Future<List<Article>> _futureArticles;
  List<Article> _fetchedArticles = [];
  int _currentPageNumber = 1;
  String _tagId = '';
  bool _isNetworkError = false;
  bool _isLoading = false;

  // 取得した記事の内容を整理して表示
  Widget _articleWidget(Article article) {
    DateTime postedTime = DateTime.parse(article.createdAt);
    String postedDate = Constants.postedDateFormat.format(postedTime);

    String userIconUrl = article.user.iconUrl;
    if (userIconUrl.isEmpty) {
      userIconUrl = Constants.defaultUserIconUrl;
    }

    return ListTile(
      onTap: () {
        ScrollableModalBottomSheet.showWebContent(context, _tagId, article.url);
      },
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: CachedNetworkImageProvider(userIconUrl),
      ),
      title: Text(
        article.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      subtitle: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0xE2E2E2FF),
              width: 1.0,
            ),
          ),
        ),
        child: Text(
          '${article.user.id} 投稿日: $postedDate LGTM: ${article.likesCount}',
        ),
      ),
    );
  }

  // 記事一覧をListで表示
  Widget _articleListView() {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8.0),
          color: const Color(0xFFF2F2F2),
          alignment: Alignment.centerLeft,
          child: const Text(
            '投稿記事',
            style: TextStyle(
              color: const Color(0xFF828282),
            ),
          ),
        ),
        Flexible(
          child: RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _fetchedArticles.length,
              controller: _scrollController,
              itemBuilder: (context, index) {
                return _articleWidget(_fetchedArticles[index]);
              },
            ),
          ),
        )
      ],
    );
  }

  // 記事を再読み込み
  Future<void> _reload() async {
    setState(() {
      _futureArticles = Client.fetchTagDetail(_currentPageNumber, _tagId);
    });
  }

  // 記事を追加読み込み
  Future<void> _moreLoad() async {
    if (!_isLoading) {
      _isLoading = true;
      _currentPageNumber++;
      setState(() {
        _futureArticles = Client.fetchArticle(_currentPageNumber, _tagId);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tagId = widget.tag.id;
    _futureArticles = Client.fetchTagDetail(_currentPageNumber, _tagId);
    _scrollController.addListener(() {
      if (_scrollController.isBottom) {
        _moreLoad();
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 1.6,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: const Color(0xFF468300),
          ),
        ),
        title: Text(
          _tagId,
          style: Constants.headerTextStyle,
        ),
      ),
      body: FutureBuilder(
        future: _futureArticles,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Widget child = Container();

          if (snapshot.hasError) {
            _isNetworkError = true;
            child = ErrorView.errorViewWidget(_reload);
          } else if (_currentPageNumber != 1) {
            child = _articleListView();
          }

          if (snapshot.connectionState == ConnectionState.done) {
            _isLoading = false;
            if (snapshot.hasData) {
              _isNetworkError = false;
              if (_currentPageNumber == 1) {
                _fetchedArticles = snapshot.data;
                child = _articleListView();
              } else {
                _fetchedArticles.addAll(snapshot.data);
              }
            } else if (snapshot.hasError) {
              _isNetworkError = true;
              child = ErrorView.errorViewWidget(_reload);
            }
          } else {
            if (_isNetworkError || _currentPageNumber == 1) {
              child = CircularProgressIndicator();
            }
          }
          return Container(
            child: Center(
              child: child,
            ),
          );
        },
      ),
    );
  }
}
