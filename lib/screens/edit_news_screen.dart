import 'package:flutter/material.dart';
import '../models/news.dart';
import '../services/news_service.dart';
import '../widgets/category_dropdown.dart';

class EditNewsScreen extends StatefulWidget {
  final News? initial;

  const EditNewsScreen({super.key, this.initial});

  @override
  State<EditNewsScreen> createState() => _EditNewsScreenState();
}

class _EditNewsScreenState extends State<EditNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _imageUrl = TextEditingController();

  String? _categoryId;
  String _categoryName = '';
  String _status = 'published';

  // 🔹 new trending flag
  bool _isTrending = false;

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
      _isTrending = n.isTrending; // load existing trending state
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null || _categoryId!.isEmpty) return;

    final n = News(
      id: widget.initial?.id,
      title: _title.text.trim(),
      content: _content.text.trim(),
      imageUrl: _imageUrl.text.trim(),
      type: 'article',
      status: _status,
      categoryId: _categoryId!,
      categoryName: _categoryName,
      isTrending: _isTrending, // ✅ save trending
      views: widget.initial?.views ?? 0, // ✅ preserve views if editing
    );

    final service = NewsService();
    if (widget.initial == null) {
      await service.createNews(n);
    } else {
      await service.updateNews(n);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit News' : 'Add News')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _content,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _imageUrl,
              decoration:
                  const InputDecoration(labelText: 'Image URL (optional)'),
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
            const SizedBox(height: 12),

            // ✅ Switch to mark as trending
            SwitchListTile(
              title: const Text('Mark as Trending'),
              value: _isTrending,
              onChanged: (v) => setState(() => _isTrending = v),
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
