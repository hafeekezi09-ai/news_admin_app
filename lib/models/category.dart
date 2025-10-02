class Category {
  final String? id;
  final String name;
  final String type;
  final String? content;
  final String? coverUrl;

  //  optional feature fields
  final String? featureTitle;
  final String? featureContent;
  final String? featureImageUrl;

  Category({
    this.id,
    required this.name,
    required this.type,
    this.content,
    this.coverUrl,
    this.featureTitle,
    this.featureContent,
    this.featureImageUrl,
  });

  factory Category.fromMap(String id, Map<String, dynamic> m) {
    return Category(
      id: id,
      name: m['name'] as String? ?? '',
      type: m['type'] as String? ?? '',
      content: m['content'] as String?,          
      coverUrl: m['coverUrl'] as String?,
      featureTitle: m['featureTitle'] as String?,
      featureContent: m['featureContent'] as String?,
      featureImageUrl: m['featureImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      if (content != null && content!.isNotEmpty) 'content': content,
      if (coverUrl != null && coverUrl!.isNotEmpty) 'coverUrl': coverUrl,
      if (featureTitle != null && featureTitle!.isNotEmpty) 'featureTitle': featureTitle,
      if (featureContent != null && featureContent!.isNotEmpty) 'featureContent': featureContent,
      if (featureImageUrl != null && featureImageUrl!.isNotEmpty) 'featureImageUrl': featureImageUrl,
    };
  }
}
