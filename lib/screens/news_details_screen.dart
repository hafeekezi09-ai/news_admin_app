import 'package:flutter/material.dart';
import '../models/news.dart';

class NewsDetailScreen extends StatelessWidget {
  final News news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(news.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ News Image
            if (news.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  news.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
                ),
              ),
            const SizedBox(height: 16),

            // ✅ Title
            Text(
              news.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // ✅ Metadata: Category & Published Date
            Row(
              children: [
                Chip(
                  label: Text(news.categoryName),
                  avatar: const Icon(Icons.category, size: 16),
                ),
                const SizedBox(width: 10),
                if (news.publishedAt != null)
                  Text(
                    "Published: ${news.publishedAt!.toLocal()}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            const Divider(height: 24),

            // ✅ Content
            Text(
              news.content,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
