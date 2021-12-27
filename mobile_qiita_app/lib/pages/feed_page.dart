import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_qiita_app/services/client.dart';
import 'package:mobile_qiita_app/services/article.dart';
import 'package:mobile_qiita_app/views/error_views.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

  late Future<List<Article>> _futureArticles;

  // 取得した記事の内容を整理して表示
  Widget _articleWidget(Article article) {
    final postedDateFormat = DateFormat('yyyy-MM-dd');
    DateTime postedTime = DateTime.parse(article.created_at);
    String postedDate = postedDateFormat.format(postedTime);

    String userIconUrl = article.user.iconUrl;
    if (userIconUrl == '') {
      userIconUrl = 'https://secure.gravatar.com/avatar/931b4bb04a18ab8874b2114493d0ea8e';
    }

    return ListTile(
      onTap: () {
        print(article.title);
        // TODO: 記事項目タップで13-Qiita Article Pageへ遷移する
      },
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: CachedNetworkImageProvider(article.user.iconUrl),
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
              color: const Color(0xEFEFF0FF),
              width: 1.0,
            ),
          ),
        ),
        child: Text(
          '${article.user.id} 投稿日: $postedDate LGTM: ${article.likes_count}',
        ),
      ),
    );
  }

  // 再読み込みする
  void _reload() {
    setState(() {
      _futureArticles = Client.fetchArticle();
    });
  }

  @override
  void initState() {
    super.initState();
    _futureArticles = Client.fetchArticle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(128.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xEFEFF0FF),
                width: 1.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Container(
                  height: 70.0,
                  alignment: Alignment.center,
                  child: const Text(
                    'Feed',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Pacifico',
                      fontSize: 22.0,
                    ),
                  ),
                ),
                Container(
                  height: 40.0,
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.only(left: 10.0),
                  decoration: BoxDecoration(
                    color: const Color(0xEFEFF0FF),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    enabled: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      icon: const Icon(Icons.search),
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        color: const Color(0xFF828282),
                        fontSize: 18.0,
                      ),
                    ),
                    onChanged: (e) {
                      print(e);
                      // TODO: Search Barに任意のテキストを入力すると記事の検索ができる
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _futureArticles,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<Widget> children = [];
          MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              print('snapshot.hasData');
              children = <Widget> [
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return _articleWidget(snapshot.data[index]);
                    },
                  ),
                ),
              ];
            }
            else if (snapshot.hasError) {
              print('snapshot.hasError');
              children = <Widget> [
                ErrorView.errorViewWidget(_reload),
              ];
            }
          } else {
            print('loading...');
            mainAxisAlignment = MainAxisAlignment.center;
            children = <Widget> [
              Center(
                child: CircularProgressIndicator(),
              ),
            ];
          }
          return Column(
            mainAxisAlignment: mainAxisAlignment,
            children: children,
          );
        },
      ),
    );
  }
}
