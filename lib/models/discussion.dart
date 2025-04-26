class Discussion {
  final String id;
  final String title;
  final String author;
  final String authorId;

  Discussion({
    required this.id,
    required this.title,
    required this.author,
    required this.authorId,
  });

  factory Discussion.fromMap(String id, Map<String, dynamic> data) {
    return Discussion(
      id: id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      authorId: data['authorId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'authorId': authorId,
    };
  }
}