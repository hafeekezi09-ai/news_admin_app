import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news.dart';

class NewsService {
  final _col = FirebaseFirestore.instance.collection('news');

  Future<void> createNews(News n) async {
    await _col.add({
      ...n.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      
      'publishedAt':
          n.status == 'published' ? FieldValue.serverTimestamp() : null,
    });
  }

  
  Future<void> updateNews(News n) async {
    if (n.id == null) throw Exception('News id required');

    
    final snap = await _col.doc(n.id!).get();
    final current = snap.data();

    final Timestamp? existingPubTs = current?['publishedAt'] as Timestamp?;

    final update = {
      ...n.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (n.status == 'published')
        
        'publishedAt': existingPubTs ?? FieldValue.serverTimestamp()
      else
        
        'publishedAt': FieldValue.delete(),
    };

    await _col.doc(n.id!).update(update);
  }
  
  Stream<List<News>> getNewsList() {
    return _col
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => News.fromMap(d.id, d.data())).toList());
  }
  
  Stream<List<News>> streamPublished() {
    return _col
        .where('status', isEqualTo: 'published')
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => News.fromMap(d.id, d.data())).toList());
  }

  
  Stream<List<News>> streamByCategory(String categoryId) {
    return _col
        .where('categoryId', isEqualTo: categoryId)
        .where('status', isEqualTo: 'published')
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => News.fromMap(d.id, d.data())).toList());
  }


  Future<void> deleteNews(String id) async {
    await _col.doc(id).delete();
  }
}
