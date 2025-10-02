import 'package:flutter/material.dart';
import '../models/news.dart';
import '../services/news_service.dart';
import 'edit_news_screen.dart';

class ViewNewsScreen extends StatefulWidget {
  const ViewNewsScreen({super.key});

  @override
  State<ViewNewsScreen> createState() => _ViewNewsScreenState();
}

class _ViewNewsScreenState extends State<ViewNewsScreen> {
  final _service = NewsService();
  String _q = ''; // simple client-side search (title/category)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All News'),
        actions: [
          // compact search
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () async {
              final text = await showSearch<String?>(
                context: context,
                delegate: _NewsSearchDelegate(initial: _q),
              );
              if (text == null) return;
              setState(() => _q = text.trim());
            },
          ),
        ],
      ),
      body: StreamBuilder<List<News>>(
        stream: _service.getNewsList(), // realtime list ordered by publishedAt
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          var items = snap.data ?? [];

          // light client-side filter
          if (_q.isNotEmpty) {
            final qLower = _q.toLowerCase();
            items = items
                .where((n) =>
                    n.title.toLowerCase().contains(qLower) ||
                    n.categoryName.toLowerCase().contains(qLower))
                .toList();
          }

          if (items.isEmpty) {
            return const Center(child: Text('No news found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final n = items[i];
              final hasImg = n.imageUrl.trim().isNotEmpty;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6), // compact
                leading: hasImg
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          n.imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
                      )
                    : const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.article),
                      ),
                title: Text(
                  n.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${n.categoryName} • ${n.status}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  // open edit directly on tap (optional)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditNewsScreen(initial: n),
                    ),
                  );
                },
                trailing: Wrap(
                  spacing: 0,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditNewsScreen(initial: n),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmAndDelete(context, n),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, News n) async {
    if (n.id == null) return;
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete News'),
            content: Text('Delete "${n.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) return;

    try {
      await _service.deleteNews(n.id!);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Deleted')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }
}

/// Small, simple search input on top of the list
class _NewsSearchDelegate extends SearchDelegate<String?> {
  _NewsSearchDelegate({String? initial}) {
    query = initial ?? '';
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    close(context, query.trim());
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox.shrink();
}
