import 'package:flutter/material.dart';
import 'package:novel_nest/screens/book_search_screen.dart';

class NovelNestDrawer extends StatelessWidget {
  const NovelNestDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.search),
            title: const Text('Book Search'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BookSearchScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.menu_book_rounded),
            title: const Text('Reading List'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BookSearchScreen()),
              ); // Change to Reading list screen
            },
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: const Text('Discussion Board'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BookSearchScreen()),
              ); // Change to discussion board screen
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: const Text('Discussion Board'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BookSearchScreen()),
              ); // Change to profile screen
            },
          ),
        ],
      ),
    );
  }
}
