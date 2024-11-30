import 'package:flutter/material.dart';
import 'try_on_image_screen.dart'; // Import the TryOnImageScreen
import 'try_on_avatar_screen.dart'; // Import the TryOnAvatarScreen
import 'create_avatar_screen.dart'; // Import the CreateAvatarScreen
import 'product_catalog_screen.dart'; // Import the ProductCatalogScreen
import 'wishlist_screen.dart'; // Import the WishlistScreen
import 'profile_screen.dart'; // Import the ProfileScreen
import 'dashboard_screen.dart'; // Import the DashboardScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(), // Use the DashboardScreen here
    const TryOnAvatarScreen(), // Use the TryOnAvatarScreen here
    const TryOnImageScreen(), // Use the TryOnImageScreen here
    const CreateAvatarScreen(), // Use the CreateAvatarScreen here
    const ProductCatalogScreen(), // Use the ProductCatalogScreen here
    const WishlistScreen(), // Use the WishlistScreen here
    const ProfileScreen(), // Use the ProfileScreen here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Try-On App'),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text('Try-On Avatar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.image),
                label: Text('Try-On Image'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.brush),
                label: Text('Customize Avatar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_bag),
                label: Text('Product Catalog'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.favorite),
                label: Text('Wishlist'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_circle),
                label: Text('Profile'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
