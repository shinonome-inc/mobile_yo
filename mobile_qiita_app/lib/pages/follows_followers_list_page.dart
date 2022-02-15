// TODO: ページネーションの実装
// TODO: User Pageへ遷移

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile_qiita_app/common/constants.dart';
import 'package:mobile_qiita_app/models/user.dart';
import 'package:mobile_qiita_app/services/qiita_client.dart';
import 'package:mobile_qiita_app/views/error_views.dart';

class FollowsFollowersListPage extends StatefulWidget {
  const FollowsFollowersListPage(
      {required this.usersType, required this.userId, Key? key})
      : super(key: key);

  final String usersType;
  final String userId;

  @override
  _FollowsFollowersListPageState createState() =>
      _FollowsFollowersListPageState();
}

class _FollowsFollowersListPageState extends State<FollowsFollowersListPage> {
  ScrollController _scrollController = ScrollController();
  late Future<List<User>> _futureUsers;
  List<User> _fetchedUsers = [];
  int _currentPageNumber = 1;
  String _usersType = '';
  String _userId = '';
  bool _isNetworkError = false;
  bool _isLoading = false;

  AppBar appBar(Widget appBarText) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 1.6,
      title: appBarText,
    );
  }

  // ユーザーのアイコン、名前、ID？を表示
  Widget userFormat(BuildContext context, User user) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: CachedNetworkImageProvider(user.iconUrl),
      ),
      title: Text(user.id),
      // subtitle: Text(user.name),
      subtitle: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0xEFEFF0FF),
              width: 1.6,
            ),
          ),
        ),
        child: Text(
          user.name,
        ),
      ),
    );
  }

  // ユーザー一覧を表示
  Widget usersListView() {
    return _fetchedUsers.length < 20
        ? RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _fetchedUsers.length,
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    return userFormat(context, _fetchedUsers[index]);
                  },
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _fetchedUsers.length,
              controller: _scrollController,
              itemBuilder: (context, index) {
                return userFormat(context, _fetchedUsers[index]);
              },
            ),
          );
  }

  // 再読み込み
  Future<void> _reload() async {
    setState(() {
      _futureUsers = QiitaClient.fetchUsers(_usersType, _userId);
    });
  }

  @override
  void initState() {
    super.initState();
    _usersType = widget.usersType;
    _userId = widget.userId;
    _futureUsers = QiitaClient.fetchUsers(_usersType, _userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 1.6,
        title: RichText(
          text: TextSpan(
              style: TextStyle(
                // TODO: Constants.headerTextStyleにColors.blackを追加
                color: Colors.black,
                fontFamily: Constants.pacifico,
              ),
              children: [
                TextSpan(
                  text: _userId,
                ),
                TextSpan(text: '\n'),
                TextSpan(
                  text: _usersType,
                  style: Constants.headerTextStyle,
                ),
              ]),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _futureUsers,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            Widget child = Container();

            if (snapshot.hasError) {
              child = ErrorView.networkErrorView(_reload);
            } else if (_currentPageNumber != 1) {
              child = usersListView();
            }

            if (snapshot.connectionState == ConnectionState.done) {
              _isLoading = false;
              if (snapshot.hasData) {
                _isNetworkError = false;
                if (_currentPageNumber == 1) {
                  _fetchedUsers = snapshot.data;
                  child = usersListView();
                } else if (snapshot.hasError) {
                  _isNetworkError = true;
                  child = ErrorView.networkErrorView(_reload);
                }
              }
            } else {
              if (_isNetworkError || _currentPageNumber == 1) {
                child = Center(child: CircularProgressIndicator());
              }
            }

            return Container(
              child: child,
            );
          },
        ),
      ),
    );
  }
}
