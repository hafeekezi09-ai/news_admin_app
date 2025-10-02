import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_admin_app/screens/news_details_screen.dart';
import '../models/news.dart';
// If you have a detail screen

class CategoryFeedScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const CategoryFeedScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    // Firestore query: all published news under this category, newest first
    final query = FirebaseFirestore.instance
        .collection('news')
        .where('categoryId', isEqualTo: categoryId)
        .where('status', isEqualTo: 'published')
        .orderBy('publishedAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text('No news in $categoryName yet.'));
          }

          final items = docs
              .map((d) => News.fromMap(d.id, d.data() as Map<String, dynamic>))
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final n = items[i];
              final hasImg = (n.imageUrl).trim().isNotEmpty;

              return Card(
                child: ListTile(
                  leading: hasImg
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            n.imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                        )
                      : const Icon(Icons.article),
                  title: Text(
                    n.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    n.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Navigate to detail only if you have the screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailScreen(news: n),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
