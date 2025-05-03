import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String bookId;
  final String authorId;
  final String author;
  final String title;
  final String content;
  final double rating;
  final DateTime time;

  Review({
    required this.bookId,
    required this.authorId,
    required this.author,
    required this.title,
    required this.content,
    required this.rating,
    required this.time,
  });

  factory Review.fromMap(Map<String, dynamic> data) {
    return Review(
      bookId: data['bookId'],
      authorId: data['authorId'],
      author: data['author'],
      title: data['title'],
      content: data['content'],
      rating: data['rating'],
      time: (data['time'] as Timestamp).toDate(),
    );
  }
}