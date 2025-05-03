import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:novel_nest/models/app_user.dart';
import 'package:novel_nest/models/book.dart';
import 'package:novel_nest/models/reading_list_entry.dart';
import 'package:novel_nest/services/auth_service.dart';
import 'package:novel_nest/services/book_service.dart';
import 'package:novel_nest/services/firestore_service.dart';
import 'package:novel_nest/widgets/app_background.dart';
import 'package:novel_nest/widgets/novel_nest_app_bar.dart';
import 'package:novel_nest/widgets/novel_nest_drawer.dart';
import 'package:provider/provider.dart';

class BookDetailsScreen extends StatefulWidget {
  final String bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late final Book book;
  AppUser? currentUser;
  ReadingListEntry? readingListEntry;
  String? readingStatus;
  bool isLoading = true;

  final List<String> statuses = [
    'Plan to Read',
    'Currently Reading',
    'Finished',
    'Dropped',
    'Remove from Reading List',
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final authService = context.read<AuthService>();
    final bookService = context.read<BookService>();
    final firestoreService = context.read<FirestoreService>();

    final user = await authService.getCurrentUser();
    final bookDetails = await bookService.getBookById(widget.bookId);
    readingListEntry = await firestoreService.getReadingListEntry(
      userId: user?.id ?? '',
      bookId: widget.bookId,
    );

    setState(() {
      currentUser = user;
      book = bookDetails;
      readingStatus = readingListEntry?.status;
      isLoading = false;
    });
  }

  Widget _buildBookImage() {
    if (book.thumbnail != null) {
      return Padding(
        padding: const EdgeInsets.all(15),
        child: Image.network(
          book.thumbnail!,
          width: 120,
          height: 180,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return const Icon(
        Icons.book,
        size: 120,
        color: Colors.grey,
      );
    }
  }

  String _getBookRating() {
    if (book.averageRating == null) {
      return "N/A";
    }
    return '${book.averageRating!.toStringAsFixed(1)} / 5';
  }

  Future<void> _updateReadingListEntry(String? newStatus) async {
    if (newStatus == null || currentUser == null) {
      return;
    }

    // Check for meaningless updates
    if (readingStatus == newStatus ||
        (readingListEntry == null && newStatus == 'Remove from Reading List')) {
      return;
    }

    setState(() {
      readingStatus =
          (newStatus == 'Remove from Reading List') ? null : newStatus;
    });

    final firestoreService = context.read<FirestoreService>();

    try {
      if (newStatus == 'Remove from Reading List') {
        await firestoreService.deleteReadingListEntry(
          userId: currentUser!.id,
          bookId: widget.bookId,
        );
        readingListEntry = null;
      } else if (readingListEntry == null) {
        await firestoreService.addToReadingList(
          book: book,
          userId: currentUser!.id,
          status: newStatus,
        );
        readingListEntry = await firestoreService.getReadingListEntry(
          userId: currentUser!.id,
          bookId: widget.bookId,
        );
      } else {
        await firestoreService.updateReadingListEntry(
          userId: currentUser!.id,
          bookId: widget.bookId,
          status: newStatus,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update reading list')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NovelNestAppBar(showBackButton: true),
      drawer: const NovelNestDrawer(),
      body: AppBackground(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 8,
                      ),
                      child: Text(
                        book.title,
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
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
                      child: Column(
                        children: [
                          _buildBookImage(),
                          Text(
                            book.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            book.authors?.join(', ') ?? 'Unknown Author',
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 5,
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              Text(_getBookRating()),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              spacing: 5,
                              children: [
                                const Text(
                                  'Reading Status:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                DropdownButton<String>(
                                  value: readingStatus,
                                  hint: const Text('Select status'),
                                  borderRadius: BorderRadius.circular(5),
                                  items: statuses.map((String status) {
                                    return DropdownMenuItem<String>(
                                      value: status,
                                      child: Text(status),
                                    );
                                  }).toList(),
                                  onChanged: _updateReadingListEntry,
                                ),
                              ],
                            ),
                          ),
                          Html(
                            data: book.description?.replaceAll(
                                    RegExp(r'(<br\s*/?>)+$'), '') ??
                                'No description available',
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
