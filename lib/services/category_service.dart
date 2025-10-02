import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryService {
  final _col = FirebaseFirestore.instance.collection('categories');

  Stream<List<Category>> streamAll() => _col.snapshots().map(
        (s) => s.docs.map((d) => Category.fromMap(d.id, d.data())).toList(),
      );

  Stream<List<Category>> streamByType(String type) => _col
      .where('type', isEqualTo: type)
      .snapshots()
      .map((s) => s.docs.map((d) => Category.fromMap(d.id, d.data())).toList());

  Future<String> createCategory(Category c) async {
    final ref = await _col.add(c.toMap());
    return ref.id;
  }

  Future<void> updateCategory(String id, Category c) async {
    await _col.doc(id).update(c.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _col.doc(id).delete();
  }
}
