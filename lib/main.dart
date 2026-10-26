
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'article_model.dart';

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Berita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const NewsScreen(),
    );
  }
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController =
      ScrollController();

  late Future<List<Article>> _articlesFuture;
  bool _showTopButton = false;

  @override
  void initState() {
    super.initState();

    _loadArticles();

    _scrollController.addListener(() {
      final shouldShow =
          _scrollController.offset > 300;

      if (shouldShow != _showTopButton && mounted) {
        setState(() {
          _showTopButton = shouldShow;
        });
      }
    });
  }

  void _loadArticles() {
    _articlesFuture = _apiService.fetchArticles();
  }

  Future<void> _refreshArticles() async {
    setState(() {
      _loadArticles();
    });

    try {
      await _articlesFuture;
    } catch (_) {
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.newspaper),
            SizedBox(width: 10),
            Text(
              'Berita Terkini',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang berita',
            onPressed: _refreshArticles,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: FutureBuilder<List<Article>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          // Tampilan loading
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Sedang memuat berita...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gagal memuat berita',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refreshArticles,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final articles = snapshot.data ?? [];

          if (articles.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshArticles,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Text(
                      'Tidak ada berita ditemukan.',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshArticles,
            child: ListView.builder(
              controller: _scrollController,
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];

                return Card(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(
                    bottom: 16,
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      if (article.urlToImage != null &&
                          article.urlToImage!.isNotEmpty)
                        Image.network(
                          article.urlToImage!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) {
                            return Container(
                              height: 150,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons
                                      .image_not_supported,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        ),

                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            if (article.sourceName != null)
                              Text(
                                article.sourceName!,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),

                            const SizedBox(height: 8),

                            Text(
                              article.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              article.description ??
                                  'Tidak ada deskripsi.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: _showTopButton
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              tooltip: 'Kembali ke atas',
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}

//FutureBuilder berguna karena dapat menangani proses pengambilan data yang membutuhkan waktu.
//Widget ini menampilkan status loading, error jika terjadi kegagalan, dan data ketika berhasil diterima dari API.