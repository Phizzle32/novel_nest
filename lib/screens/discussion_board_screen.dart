import 'package:flutter/material.dart';
import 'package:novel_nest/models/app_user.dart';
import 'package:novel_nest/models/discussion.dart';
import 'package:novel_nest/screens/discussion_screen.dart';
import 'package:novel_nest/services/auth_service.dart';
import 'package:novel_nest/services/firestore_service.dart';
import 'package:novel_nest/widgets/app_background.dart';
import 'package:novel_nest/widgets/discussion_dialog.dart';
import 'package:novel_nest/widgets/novel_nest_app_bar.dart';
import 'package:novel_nest/widgets/novel_nest_drawer.dart';
import 'package:provider/provider.dart';

class DiscussionBoardScreen extends StatefulWidget {
  const DiscussionBoardScreen({super.key});

  @override
  State<DiscussionBoardScreen> createState() => _DiscussionBoardScreenState();
}

class _DiscussionBoardScreenState extends State<DiscussionBoardScreen> {
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final authService = context.read<AuthService>();
    final user = await authService.getCurrentUser();
    setState(() {
      currentUser = user;
    });
  }

  Stream<List<Discussion>> _getDiscussions() {
    final firestoreService = context.read<FirestoreService>();
    return firestoreService.getDiscussionsStream();
  }

  void _addDiscussion() {
    showDialog(
      context: context,
      builder: (context) => DiscussionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const NovelNestAppBar(),
      drawer: const NovelNestDrawer(),
      body: AppBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'Discussion Board',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 30,
                ),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueGrey),
                  color: const Color(0xFFF5F5F5),
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: StreamBuilder<List<Discussion>>(
                  stream: _getDiscussions(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Failed to load discussions'));
                    }
                    final discussions = snapshot.data ?? [];
                    if (discussions.isEmpty) {
                      return const Center(
                          child: Text('No discussions available'));
                    }

                    return ListView.builder(
                      itemCount: discussions.length,
                      itemBuilder: (context, index) {
                        final discussion = discussions[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            title: Text(discussion.title),
                            subtitle: Text('By ${discussion.author}'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DiscussionScreen(discussion: discussion),
                                ),
                              );
                            },
                            onLongPress: () {
                              if (discussion.authorId == currentUser?.id) {
                                showDialog(
                                  context: context,
                                  builder: (context) => DiscussionDialog(
                                    editDiscussion: discussion,
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDiscussion,
        tooltip: 'Add Discussion',
        backgroundColor: const Color(0xFFEFE4DA),
        child: const Icon(Icons.add),
      ),
    );
  }
}
