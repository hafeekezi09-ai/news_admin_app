import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  final String? id;
  final String title;
  final String content;
  final String imageUrl;
  final String type;
  final String status;
  final String categoryId;
  final String categoryName;
  final DateTime? publishedAt;

  // 🔹 New fields
  final bool isTrending;
  final int views;

  News({
    this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.type,
    required this.status,
    required this.categoryId,
    required this.categoryName,
    this.publishedAt,
    this.isTrending = false, // default
    this.views = 0,          // default
  });

  factory News.fromMap(String id, Map<String, dynamic> m) => News(
        id: id,
        title: (m['title'] ?? '').toString(),
        content: (m['content'] ?? '').toString(),
        imageUrl: (m['imageUrl'] ?? '').toString(),
        type: (m['type'] ?? '').toString(),
        status: (m['status'] ?? 'draft').toString(),
        categoryId: (m['categoryId'] ?? '').toString(),
        categoryName: (m['categoryName'] ?? '').toString(),
        publishedAt: (m['publishedAt'] is Timestamp)
            ? (m['publishedAt'] as Timestamp).toDate()
            : null,
        isTrending: m['isTrending'] as bool? ?? false,
        views: (m['views'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'content': content,
        'imageUrl': imageUrl,
        'type': type,
        'status': status,
        'categoryId': categoryId,
        'categoryName': categoryName,
        if (publishedAt != null) 'publishedAt': publishedAt,
        'isTrending': isTrending,
        'views': views,
      };
}
