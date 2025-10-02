// lib/screens/edit_category_screen.dart
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class EditCategoryScreen extends StatefulWidget {
  final Category? initial;

  const EditCategoryScreen({super.key, this.initial});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _content = TextEditingController();
  String _type = 'magazine';
  String? _coverUrl; // <- keep your existing field

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    if (c != null) {
      _name.text = c.name;
      _content.text = c.content ?? '';
      _type = c.type;
      _coverUrl = c.coverUrl;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final c = Category(
      id: widget.initial?.id,
      name: _name.text.trim(),
      type: _type,
      content: _content.text.trim(),
      coverUrl: _coverUrl, // <- will include the Image URL if provided
    );

    final service = CategoryService();
    if (widget.initial == null) {
      await service.createCategory(c);
    } else {
      await service.updateCategory(c.id!, c);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Category' : 'Add Category')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _content,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),

              // ✅ NEW: Image URL (optional) — minimal change
              TextFormField(
                initialValue: _coverUrl ?? '',
                onChanged: (v) => _coverUrl = v.trim(),
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                  hintText: 'https://example.com/cover.jpg',
                ),
              ),
              const SizedBox(height: 8),
              if ((_coverUrl ?? '').isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _coverUrl!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(height: 140, child: Center(child: Icon(Icons.broken_image))),
                  ),
                ),

              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'magazine', child: Text('Magazine')),
                  DropdownMenuItem(value: 'newspaper', child: Text('Newspaper')),
                  DropdownMenuItem(value: 'article', child: Text('Article')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'magazine'),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: Text(isEdit ? 'Update' : 'Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
