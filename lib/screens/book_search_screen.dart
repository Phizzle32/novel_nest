import 'package:flutter/material.dart';
import 'package:novel_nest/widgets/novel_nest_app_bar.dart';
import 'package:novel_nest/widgets/novel_nest_drawer.dart';

class BookSearchScreen extends StatefulWidget {
  const BookSearchScreen({super.key});

  @override
  State<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NovelNestAppBar(),
      drawer: const NovelNestDrawer(),
      body: const Center(
        child: Text('Book Search Screen'),
      ),
    );
  }
}