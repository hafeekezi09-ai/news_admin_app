// lib/screens/manage_categories_screen.dart
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import 'edit_category_screen.dart'; // if you have an edit/create screen

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Category'),
            content: Text('Are you sure you want to delete "$name"?'),
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
  }

  @override
  Widget build(BuildContext context) {
    final service = CategoryService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            tooltip: 'Add',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditCategoryScreen()),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<List<Category>>(
        stream: service.streamAll(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No categories yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final c = items[i];
              final hasImg = (c.coverUrl ?? '').isNotEmpty;

              return ListTile(
                leading: hasImg
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(c.coverUrl!),
                      )
                    : const CircleAvatar(child: Icon(Icons.category)),
                title: Text(
                  c.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  [
                    c.type,
                    if ((c.content ?? '').isNotEmpty) c.content!,
                  ].join(' • '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditCategoryScreen(initial: c),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // c.id is String? in the model; ensure non-null before passing
                        if (c.id == null || c.id!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Cannot delete: invalid id')),
                          );
                          return;
                        }
                        final ok = await _confirmDelete(context, c.name);
                        if (!ok) return;

                        try {
                          await CategoryService().deleteCategory(c.id!); // ✅ fix
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Deleted "${c.name}"')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Delete failed: $e')),
                            );
                          }
                        }
                      },
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
}
