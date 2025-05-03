import 'package:flutter/material.dart';
import 'package:novel_nest/models/app_user.dart';
import 'package:novel_nest/models/book.dart';
import 'package:novel_nest/models/reading_list_entry.dart';
import 'package:novel_nest/services/auth_service.dart';
import 'package:novel_nest/services/firestore_service.dart';
import 'package:novel_nest/widgets/app_background.dart';
import 'package:novel_nest/widgets/book_list_tile.dart';
import 'package:novel_nest/widgets/novel_nest_app_bar.dart';
import 'package:novel_nest/widgets/novel_nest_drawer.dart';
import 'package:provider/provider.dart';

class ReadingListScreen extends StatefulWidget {
  const ReadingListScreen({super.key});

  @override
  State<ReadingListScreen> createState() => _ReadingListScreenState();
}

class _ReadingListScreenState extends State<ReadingListScreen> {
  List<ReadingListEntry> planToRead = [];
  List<ReadingListEntry> currentlyReading = [];
  List<ReadingListEntry> finished = [];
  List<ReadingListEntry> dropped = [];
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  void _fetchUser() async {
    final authService = context.read<AuthService>();
    final user = await authService.getCurrentUser();

    setState(() {
      currentUser = user;
    });
  }

  Stream<List<ReadingListEntry>> _getReadingList() {
    if (currentUser == null) {
      return Stream.value([]);
    }
    final firestoreService = context.read<FirestoreService>();
    return firestoreService.getReadingListStream(currentUser!.id);
  }

  Widget _buildSection(String title, List<ReadingListEntry> entries) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueGrey),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...entries.map((entry) {
                final book = Book(
                  id: entry.bookId,
                  title: entry.title,
                  authors: entry.authors,
                  thumbnail: entry.thumbnail,
                );
                return BookListTile(book: book);
              }),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NovelNestAppBar(),
      drawer: const NovelNestDrawer(),
      body: AppBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'Reading List',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ReadingListEntry>>(
                stream: _getReadingList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No books in your reading list'));
                  }

                  List<ReadingListEntry> readingList = snapshot.data!;

                  List<ReadingListEntry> planToRead = [];
                  List<ReadingListEntry> currentlyReading = [];
                  List<ReadingListEntry> finished = [];
                  List<ReadingListEntry> dropped = [];

                  for (var entry in readingList) {
                    switch (entry.status) {
                      case 'Plan to Read':
                        planToRead.add(entry);
                        break;
                      case 'Currently Reading':
                        currentlyReading.add(entry);
                        break;
                      case 'Finished':
                        finished.add(entry);
                        break;
                      case 'Dropped':
                        dropped.add(entry);
                        break;
                      default:
                        break;
                    }
                  }
                  return SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
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
                      child: Column(
                        spacing: 15,
                        children: [
                          if (planToRead.isNotEmpty)
                            _buildSection('Plan to Read', planToRead),
                          if (currentlyReading.isNotEmpty)
                            _buildSection(
                                'Currently Reading', currentlyReading),
                          if (finished.isNotEmpty)
                            _buildSection('Finished', finished),
                          if (dropped.isNotEmpty)
                            _buildSection('Dropped', dropped),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
