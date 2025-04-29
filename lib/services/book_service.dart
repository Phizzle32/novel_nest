import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:novel_nest/models/book.dart';

// Service for interacting with the Google Books API
class BookService {
  static const _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  /// Search for books
  Future<List<Book>> searchBooks(String query) async {
    final url = Uri.parse('$_baseUrl?q=$query');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['items'] as List?;

      if (items == null) return [];

      return items.map((item) => Book.fromMap(item)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  // Retrieve a certain book by its id
  Future<Book> getBookById(String id) async {
    final url = Uri.parse('$_baseUrl/$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Book.fromMap(data);
    } else {
      throw Exception('Failed to load book details for ID: $id');
    }
  }

  // Get recommended books based on preferred genres
  Future<List<Book>> getBookRecommendations(
      List<String> preferredGenres) async {
    final List<Book> recommended = [];
    final seenIds = <String>{};

    for (String genre in preferredGenres) {
      try {
        final books = await searchBooks(genre);

        for (Book book in books) {
          if (!seenIds.contains(book.id)) {
            recommended.add(book);
            seenIds.add(book.id);
          }
        }
      } catch (e) {
        throw Exception('Error fetching books for genre $genre: $e');
      }
    }

    recommended.shuffle();
    return recommended;
  }
}
