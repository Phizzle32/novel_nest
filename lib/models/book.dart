class Book {
  final String id;
  final String title;
  final String? subtitle;
  final List<String>? authors;
  final String? description;
  final String? thumbnail;
  final double? averageRating;
  final int? ratingsCount;

  Book({
    required this.id,
    required this.title,
    this.subtitle,
    this.authors,
    this.description,
    this.thumbnail,
    this.averageRating,
    this.ratingsCount,
  });

  factory Book.fromMap(Map<String, dynamic> data) {
    final volumeInfo = data['volumeInfo'];

    return Book(
      id: data['id'],
      title: volumeInfo['title'] ?? 'No Title',
      subtitle: volumeInfo['subtitle'],
      authors: (volumeInfo['authors'] as List?)?.cast<String>(),
      description: volumeInfo['description'],
      thumbnail: volumeInfo['imageLinks']?['thumbnail'],
      averageRating: volumeInfo['averageRating']?.toDouble(),
      ratingsCount: volumeInfo['ratingsCount'],
    );
  }
}