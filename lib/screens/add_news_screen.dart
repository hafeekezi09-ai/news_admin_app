import 'package:flutter/material.dart';
import '../models/news.dart';
import '../services/news_service.dart';
import '../widgets/category_dropdown.dart';

class AddNewsScreen extends StatefulWidget {
  const AddNewsScreen({super.key});

  @override
  State<AddNewsScreen> createState() => _AddNewsScreenState();
}

class _AddNewsScreenState extends State<AddNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _imageUrl = TextEditingController();

  String? _categoryId;
  String _categoryName = '';
  String _status = 'published';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null || _categoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final n = News(
      id: null,
      title: _title.text.trim(),
      content: _content.text.trim(),
      imageUrl: _imageUrl.text.trim(),
      type: 'article',
      status: _status,
      categoryId: _categoryId!,
      categoryName: _categoryName,
      publishedAt: _status == 'published' ? DateTime.now() : null,
    );

    final service = NewsService();
    await service.createNews(n);

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('News created')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add News')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _content,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _imageUrl,
              decoration:
                  const InputDecoration(labelText: 'Image URL (optional)'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            CategoryDropdown(
              value: _categoryId,
              onChanged: (id, name) {
                setState(() {
                  _categoryId = id;
                  _categoryName = name;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              items: const [
                DropdownMenuItem(value: 'draft', child: Text('Draft')),
                DropdownMenuItem(value: 'published', child: Text('Published')),
              ],
              onChanged: (v) => setState(() => _status = v ?? 'draft'),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
