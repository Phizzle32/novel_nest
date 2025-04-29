import 'package:flutter/material.dart';
import 'package:novel_nest/models/app_user.dart';
import 'package:novel_nest/models/book.dart';
import 'package:novel_nest/services/auth_service.dart';
import 'package:novel_nest/services/book_service.dart';
import 'package:novel_nest/widgets/novel_nest_app_bar.dart';
import 'package:novel_nest/widgets/novel_nest_drawer.dart';
import 'package:provider/provider.dart';

class BookSearchScreen extends StatefulWidget {
  const BookSearchScreen({super.key});

  @override
  State<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  AppUser? currentUser;
  List<Book> books = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final authService = context.read<AuthService>();
    final user = await authService.getCurrentUser();

    setState(() {
      currentUser = user;
    });

    _getRecommendations();
  }

  Future<void> _getRecommendations() async {
    if (currentUser != null && currentUser!.preferredGenres.isNotEmpty) {
      final bookService = context.read<BookService>();
      final recommendedBooks = await bookService
          .getBookRecommendations(currentUser!.preferredGenres);
      setState(() {
        books = recommendedBooks;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NovelNestAppBar(),
      drawer: const NovelNestDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFC4DDE9),
              const Color(0xFFDFD5E7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return ListTile(
                    leading: book.thumbnail != null
                        ? Image.network(
                            book.thumbnail!,
                            width: 50,
                            height: 75,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.broken_image),
                          )
                        : Icon(Icons.book, size: 50),
                    title: Text(book.title),
                    subtitle: Text(book.authors?.join(', ') ?? ''),
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
