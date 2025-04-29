import 'package:flutter/material.dart';
import 'package:novel_nest/models/book.dart';
import 'package:novel_nest/screens/book_details_screen.dart';

class BookListTile extends StatelessWidget {
  final Book book;

  const BookListTile({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: book.thumbnail != null
            ? Image.network(
                book.thumbnail!,
                width: 50,
                height: 75,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.broken_image),
              )
            : Icon(Icons.book, size: 50),
        title: Text(book.title),
        subtitle: Text(book.authors?.join(', ') ?? 'Unknown Author'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailsScreen(book: book),
            ),
          );
        },
      ),
    );
  }
}
