import 'dart:convert';

import 'package:http/http.dart' as http;

import 'article_model.dart';

class ApiService {
  // Ganti dengan API key NewsAPI milik kamu.
  static const String _apiKey = '83bb96dfd77048a29efee2f21ceba043';

  Future<List<Article>> fetchArticles() async {
    if (_apiKey == 'MASUKKAN_API_KEY_KAMU') {
      throw Exception('Masukkan API key NewsAPI terlebih dahulu.');
    }

    final url = Uri.https('newsapi.org', '/v2/top-headlines', {
      'country': 'id',
      'apiKey': _apiKey,
      'pageSize': '30',
    });

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 20));

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 || data['status'] != 'ok') {
        throw Exception(data['message'] ?? 'Gagal mengambil berita.');
      }

      final List<dynamic> articlesJson = data['articles'] as List<dynamic>;

      return articlesJson
          .whereType<Map<String, dynamic>>()
          .map((json) => Article.fromJson(json))
          .toList();
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal menghubungi server: $e');
    }
  }
}
