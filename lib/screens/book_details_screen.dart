import 'package:flutter/material.dart';
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
  AppUser? currentUser;
  late final Book book;
  late final ReadingListEntry? readingListEntry;
  bool isLoading = true;

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
    final readingListEntryDetails = await firestoreService.getReadingListEntry(
      userId: user?.id ?? '',
      bookId: widget.bookId,
    );

    setState(() {
      currentUser = user;
      book = bookDetails;
      readingListEntry = readingListEntryDetails;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NovelNestAppBar(showBackButton: true),
      drawer: const NovelNestDrawer(),
      body: AppBackground(
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Text(
                  book.title,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
        ),
      ),
    );
  }
}
