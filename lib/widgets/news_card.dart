import 'package:flutter/material.dart';

class NewsCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const NewsCard({super.key, required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
        title: Text(title),
      ),
    );
  }
}
