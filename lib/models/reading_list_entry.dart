class ReadingListEntry {
  final String bookId;
  final String userId;
  final String title;
  final List<String>? authors;
  final String? thumbnail;
  final String status;

  ReadingListEntry({
    required this.bookId,
    required this.userId,
    required this.title,
    required this.authors,
    required this.thumbnail,
    required this.status,
  });

  factory ReadingListEntry.fromMap(Map<String, dynamic> data) {
    return ReadingListEntry(
      bookId: data['bookId'] as String,
      userId: data['userId'] as String,
      title: data['title'] as String,
      authors: List<String>.from(data['authors'] ?? []),
      thumbnail: data['thumbnail'] as String?,
      status: data['status'] as String,
    );
  }
}
