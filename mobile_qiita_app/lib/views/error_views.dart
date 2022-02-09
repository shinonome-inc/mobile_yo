import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorView {
  // ネットワークエラー
  static Widget networkErrorView(Function onTapReload) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(),
            Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 72.0,
                    width: 72.0,
                    child: Image.asset(
                      'assets/images/network_error.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 40.0, bottom: 8.0),
                    child: const Text(
                      'ネットワークエラー',
                    ),
                  ),
                  const Text(
                    'お手数ですが電波の良い場所で\n再度読み込みをお願いします',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            FlatButton(
              onPressed: () {
                onTapReload();
              },
              height: 48.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(24.0),
                ),
              ),
              child: const Text(
                '再読み込みする',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // 検索結果が0件だった場合に表示
  static Widget emptySearchResultView() {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '検索にマッチする記事はありませんでした',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20.0),
            const Text(
              '検索条件を変えるなどして再度検索をしてください',
              style: TextStyle(color: const Color(0xFF828282)),
            ),
          ],
        ),
      ),
    );
  }

  // 未ログインの場合に表示
  static Widget notLoginView(/* Function onTapLogin */) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(),
              Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 40.0, bottom: 8.0),
                      child: const Text(
                        'ログインが必要です',
                      ),
                    ),
                    const Text(
                      'マイページの機能を利用するには\nログインを行っていただく必要があります。',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              FlatButton(
                onPressed: () {
                  // onTapLogin();
                },
                height: 48.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(24.0),
                  ),
                ),
                child: const Text(
                  'ログインする',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
