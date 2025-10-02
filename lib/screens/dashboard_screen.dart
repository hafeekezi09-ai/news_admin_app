// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'manage_categories_screen.dart';
import 'add_news_screen.dart';
import 'view_news_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Center(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            _DashboardCard(
              title: 'Categories',
              icon: Icons.category,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageCategoriesScreen(),
                ),
              ),
            ),
            _DashboardCard(
              title: 'Add News',
              icon: Icons.add,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddNewsScreen()),
              ),
            ),
            _DashboardCard(
              title: 'View News',
              icon: Icons.article,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewNewsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 130, // ✅ smaller width
        height: 120, // ✅ smaller height
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: Theme.of(context).primaryColor,
              ), // smaller icon
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 14)), // smaller text
            ],
          ),
        ),
      ),
    );
  }
}
