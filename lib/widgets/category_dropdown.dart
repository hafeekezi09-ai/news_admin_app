
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryDropdown extends StatelessWidget {
  final String? value;
  final void Function(String id, String name) onChanged;
  final String? typeFilter; 

  const CategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.typeFilter,
  });

  @override
  Widget build(BuildContext context) {
    final service = CategoryService();
    final stream =
        typeFilter == null ? service.streamAll() : service.streamByType(typeFilter!);

    return StreamBuilder<List<Category>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }
        final cats = snap.data ?? [];
        return DropdownButtonFormField<String>(
          value: value,
          items: cats
              .map((c) => DropdownMenuItem(
                    value: c.id,
                    onTap: () => onChanged(c.id!, c.name),
                    child: Text('${c.name} • ${c.type}'),
                  ))
              .toList(),
          decoration: const InputDecoration(labelText: 'Category'),
          onChanged: (v) {
            final found = cats.firstWhere(
              (c) => c.id == v,
              orElse: () => Category(id: v, name: '', type: ''),
            );
            onChanged(v ?? '', found.name);
          },
          validator: (v) => v == null || v.isEmpty ? 'Choose a category' : null,
        );
      },
    );
  }
}
