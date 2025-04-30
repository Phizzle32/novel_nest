import 'package:flutter/material.dart';
import 'package:novel_nest/models/app_user.dart';
import 'package:novel_nest/screens/book_search_screen.dart';
import 'package:novel_nest/screens/discussion_board_screen.dart';
import 'package:novel_nest/screens/profile_screen.dart';
import 'package:novel_nest/services/auth_service.dart';
import 'package:provider/provider.dart';

class NovelNestDrawer extends StatefulWidget {
  const NovelNestDrawer({super.key});

  @override
  State<NovelNestDrawer> createState() => _NovelNestDrawerState();
}

class _NovelNestDrawerState extends State<NovelNestDrawer> {
  AppUser? user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final authService = context.read<AuthService>();
    final currentUser = await authService.getCurrentUser();

    if (mounted) {
      setState(() {
        user = currentUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFC4DDE9),
                    Color(0xFFDFD5E7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 8,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 60,
                    color: Colors.blueGrey,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Guest',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ],
              ),
            ),
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
                  MaterialPageRoute(
                      builder: (context) => DiscussionBoardScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
