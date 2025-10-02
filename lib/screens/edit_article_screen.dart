import 'package:flutter/material.dart';
import '../models/news.dart';
import '../services/news_service.dart';
import '../widgets/category_dropdown.dart';

class EditArticleScreen extends StatefulWidget {
  final News? initial; // null => create

  const EditArticleScreen({super.key, this.initial});

  @override
  State<EditArticleScreen> createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends State<EditArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _imageUrl = TextEditingController();

  String? _categoryId;        // will hold the id from CategoryDropdown
  String _categoryName = '';  // will hold the name from CategoryDropdown
  String _status = 'published'; // or 'draft'

  @override
  void initState() {
    super.initState();
    final n = widget.initial;
    if (n != null) {
      _title.text = n.title;
      _content.text = n.content;
      _imageUrl.text = n.imageUrl;
      _categoryId = n.categoryId;
      _categoryName = n.categoryName;
      _status = n.status;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null || _categoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a category')),
      );
      return;
    }

    final news = News(
      id: widget.initial?.id,
      title: _title.text.trim(),
      content: _content.text.trim(),
      imageUrl: _imageUrl.text.trim(),
      type: 'article',      // adjust if you use different types
      status: _status,
      categoryId: _categoryId!,   // ✅ String
      categoryName: _categoryName, // ✅ String
    );

    final service = NewsService();
    try {
      if (widget.initial == null) {
        await service.createNews(news);
      } else {
        await service.updateNews(news);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.initial == null
              ? 'News created successfully'
              : 'News updated successfully'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Article' : 'Add Article')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
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
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Content'),
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

            // ✅ Category dropdown expects String? (id), not Category
            CategoryDropdown(
              value: _categoryId, // String? id
              typeFilter: null, // or 'magazine' if you only want magazines
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
              child: Text(isEdit ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}
