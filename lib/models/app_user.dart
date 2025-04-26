class AppUser {
  final String id;
  final String email;
  final String displayName;
  final List<String> preferredGenres;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.preferredGenres,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      preferredGenres: List<String>.from(data['preferredGenres'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'preferredGenres': preferredGenres,
    };
  }
}