import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile_qiita_app/common/variables.dart';
import 'package:mobile_qiita_app/models/article.dart';
import 'package:mobile_qiita_app/models/tag.dart';
import 'package:mobile_qiita_app/qiita_auth_key.dart';

class Client {
  // static Map<String, String>? _authorizationRequestHeader = {
  //   'Authorization': 'Bearer ${Variables.accessToken}',
  // };

  // アクセストークン発行
  static Future<void> fetchAccessToken() async {
    var url = 'https://qiita.com/api/v2/access_tokens';
    print(Variables.redirectUrlCode);
    var response = await http.post(
      Uri.parse(url),
      headers: {'content-type': 'application/json'},
      body: {
        'client_id': QiitaAuthKey.clientId,
        'client_secret': QiitaAuthKey.clientSecret,
        'code': Variables.redirectUrlCode,
      },
    );
    print(response.statusCode);
    print(response.body);
  }

  // QiitaAPIで記事を取得
  static Future<List<Article>> fetchArticle(
      int currentPageNumber, String searchWord) async {
    var url = searchWord.isEmpty
        ? 'https://qiita.com/api/v2/items?page=$currentPageNumber'
        : 'https://qiita.com/api/v2/items?page=$currentPageNumber&query=$searchWord';

    var response = Variables.redirectUrlCode.isNotEmpty
        ? await http.get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer ${Variables.accessToken}',
            },
          )
        : await http.get(
            Uri.parse(url),
          );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  // QiitaAPIでタグを取得
  static Future<List<Tag>> fetchTag(int currentPageNumber) async {
    var url =
        'https://qiita.com/api/v2/tags?page=$currentPageNumber&sort=count';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Tag.fromJson(json)).toList();
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  // QiitaAPIでタグが付けられた記事を取得
  static Future<List<Article>> fetchTagDetail(
      int currentPageNumber, String tagId) async {
    var url =
        'https://qiita.com/api/v2/tags/$tagId/items?page=$currentPageNumber';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }
}
