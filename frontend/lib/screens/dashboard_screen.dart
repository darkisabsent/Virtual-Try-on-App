import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildDashboardCard(
              context,
              icon: Icons.person,
              title: 'Try-On Avatar',
              description: 'Customize and try on avatars',
              onTap: () {
                // Navigate to Try-On Avatar screen
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.image,
              title: 'Try-On Image',
              description: 'Try on clothes using images',
              onTap: () {
                // Navigate to Try-On Image screen
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.brush,
              title: 'Customize Avatar',
              description: 'Create and customize your avatar',
              onTap: () {
                // Navigate to Customize Avatar screen
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.shopping_bag,
              title: 'Product Catalog',
              description: 'Browse and shop for clothes',
              onTap: () {
                // Navigate to Product Catalog screen
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.favorite,
              title: 'Wishlist',
              description: 'View your favorite items',
              onTap: () {
                // Navigate to Wishlist screen
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.account_circle,
              title: 'Profile',
              description: 'Manage your profile',
              onTap: () {
                // Navigate to Profile screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String description,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48.0,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
