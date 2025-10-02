import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news.dart';

class NewsService {
  final _col = FirebaseFirestore.instance.collection('news');

  Future<void> createNews(News n) async {
    await _col.add({
      ...n.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      // set only when created as published
      'publishedAt':
          n.status == 'published' ? FieldValue.serverTimestamp() : null,
    });
  }

  /// Keep existing publishedAt if already set, so edits don't reorder feeds.
  Future<void> updateNews(News n) async {
    if (n.id == null) throw Exception('News id required');

    // read current doc to see if it already had publishedAt
    final snap = await _col.doc(n.id!).get();
    final current = snap.data();

    final Timestamp? existingPubTs = current?['publishedAt'] as Timestamp?;

    final update = {
      ...n.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (n.status == 'published')
        // keep existing publishedAt if present, else set now
        'publishedAt': existingPubTs ?? FieldValue.serverTimestamp()
      else
        // moving to draft -> remove publishedAt for indexing clarity
        'publishedAt': FieldValue.delete(),
    };

    await _col.doc(n.id!).update(update);
  }

  /// Realtime: all news ordered by publishedAt desc
  Stream<List<News>> getNewsList() {
    return _col
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => News.fromMap(d.id, d.data())).toList());
  }

  /// Realtime: only published news (handy for user-facing views)
  Stream<List<News>> streamPublished() {
    return _col
        .where('status', isEqualTo: 'published')
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => News.fromMap(d.id, d.data())).toList());
  }

  /// Realtime: by category (needs composite index: categoryId ASC, status ASC, publishedAt DESC)
  Stream<List<News>> streamByCategory(String categoryId) {
    return _col
        .where('categoryId', isEqualTo: categoryId)
        .where('status', isEqualTo: 'published')
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => News.fromMap(d.id, d.data())).toList());
  }

  /// 🔥 Add this so you can remove items from the View News list
  Future<void> deleteNews(String id) async {
    await _col.doc(id).delete();
  }
}
