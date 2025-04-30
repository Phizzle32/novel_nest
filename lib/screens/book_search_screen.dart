import 'dart:async';
import 'package:flutter/material.dart';
import 'package:novel_nest/models/app_user.dart';
import 'package:novel_nest/models/book.dart';
import 'package:novel_nest/services/auth_service.dart';
import 'package:novel_nest/services/book_service.dart';
import 'package:novel_nest/widgets/app_background.dart';
import 'package:novel_nest/widgets/book_list_tile.dart';
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
  Timer? _debounce;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
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
      setState(() => isLoading = true);

      final bookService = context.read<BookService>();
      final recommendedBooks = await bookService
          .getBookRecommendations(currentUser!.preferredGenres);

      setState(() {
        books = recommendedBooks;
        isLoading = false;
      });
    }
  }

  Future<void> _searchBooks(String query) async {
    setState(() => isLoading = true);
    final bookService = context.read<BookService>();
    final results = await bookService.searchBooks(query);
    setState(() {
      books = results;
      isLoading = false;
    });
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
                'Book Search',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 30,
              ),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search Books...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();

                  _debounce = Timer(const Duration(milliseconds: 400), () {
                    if (value.isEmpty) {
                      _getRecommendations();
                    } else {
                      _searchBooks(value);
                    }
                  });
                },
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : books.isEmpty
                      ? const Center(child: Text('No books found'))
                      : Container(
                          margin: const EdgeInsets.only(
                            bottom: 16,
                            right: 16,
                            left: 16,
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
                          child: ListView.builder(
                            itemCount: books.length,
                            itemBuilder: (context, index) =>
                                BookListTile(book: books[index]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
