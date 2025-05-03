import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:novel_nest/models/app_user.dart';
import 'package:novel_nest/models/book.dart';
import 'package:novel_nest/models/discussion.dart';
import 'package:novel_nest/models/message.dart';
import 'package:novel_nest/models/reading_list_entry.dart';
import 'package:novel_nest/models/review.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add user to Firestore
  Future<void> addUser({
    required String userId,
    required String email,
    required String displayName,
    required List<String> preferredGenres,
  }) async {
    try {
      await _firestore.collection('Users').doc(userId).set({
        'email': email,
        'displayName': displayName,
        'preferredGenres': preferredGenres,
      });
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }

  // Update user information in Firestore
  Future<void> updateUser({
    required AppUser user,
    String? email,
    String? displayName,
    List<String>? preferredGenres,
  }) async {
    try {
      // Create a map of the fields to update
      Map<String, dynamic> updates = {};

      if (email != null && email != user.email) {
        updates['email'] = email;
      }
      if (displayName != null && displayName != user.displayName) {
        updates['displayName'] = displayName;
        _updateUserDisplayName(user.id, displayName);
      }
      if (preferredGenres != null && preferredGenres != user.preferredGenres) {
        updates['preferredGenres'] = preferredGenres;
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('Users').doc(user.id).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Update a user's messages, discussions, and reviews with their new name
  Future<void> _updateUserDisplayName(String userId, String newName) async {
    final userMessages = await _firestore
        .collection('Messages')
        .where('userId', isEqualTo: userId)
        .get();
    final userDiscussions = await _firestore
        .collection('Discussions')
        .where('authorId', isEqualTo: userId)
        .get();
    final userReviews = await _firestore
        .collection('Reviews')
        .where('authorId', isEqualTo: userId)
        .get();

    if (userMessages.docs.isEmpty &&
        userDiscussions.docs.isEmpty &&
        userReviews.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (var doc in userMessages.docs) {
      batch.update(doc.reference, {'username': newName});
    }
    for (var doc in userDiscussions.docs) {
      batch.update(doc.reference, {'author': newName});
    }
    for (var doc in userReviews.docs) {
      batch.update(doc.reference, {'author': newName});
    }

    await batch.commit();
  }

  // Delete user from Firestore
  Future<void> deleteUser(String userId) async {
    try {
      final batch = _firestore.batch();

      // Delete the user document
      final userDoc = _firestore.collection('Users').doc(userId);
      batch.delete(userDoc);

      // Delete the user's reading list
      final readingListQuerySnapshot = await _firestore
          .collection('ReadingList')
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in readingListQuerySnapshot.docs) {
        batch.delete(doc.reference);
      }

      batch.commit();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Add discussion to Firestore
  Future<void> addDiscussion({
    required String title,
    required AppUser author,
  }) async {
    try {
      await _firestore.collection('Discussions').add({
        'title': title,
        'author': author.displayName,
        'authorId': author.id,
      });
    } catch (e) {
      throw Exception('Failed to add discussion: $e');
    }
  }

  // Update discussion in Firestore
  Future<void> updateDiscussion({
    required String discussionId,
    required String title,
  }) async {
    try {
      await _firestore.collection('Discussions').doc(discussionId).update({
        'title': title,
      });
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Delete user from Firestore
  Future<void> deleteDiscussion(String discussionId) async {
    try {
      final batch = _firestore.batch();

      // Delete the discussion document
      final discussionDoc =
          _firestore.collection('Discussions').doc(discussionId);
      batch.delete(discussionDoc);

      // Delete messages associated with the discussion
      final messagesQuerySnapshot = await _firestore
          .collection('Messages')
          .where('discussionId', isEqualTo: discussionId)
          .get();
      for (var doc in messagesQuerySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete discussion: $e');
    }
  }

  // Add message to Firestore
  Future<void> addMessage({
    required String content,
    required String discussionId,
    required AppUser author,
  }) async {
    try {
      await _firestore.collection('Messages').add({
        'content': content,
        'discussionId': discussionId,
        'time': Timestamp.now(),
        'username': author.displayName,
        'userId': author.id,
      });
    } catch (e) {
      throw Exception('Failed to add message: $e');
    }
  }

  // Add book to user's reading list in Firestore
  Future<void> addToReadingList({
    required Book book,
    required String userId,
    required String status,
  }) async {
    try {
      await _firestore.collection('ReadingList').add({
        'bookId': book.id,
        'title': book.title,
        'authors': book.authors,
        'thumbnail': book.thumbnail,
        'userId': userId,
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to add to reading list: $e');
    }
  }

  // Update a user's reading list entry in Firestore
  Future<void> updateReadingListEntry({
    required String userId,
    required String bookId,
    required String status,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('ReadingList')
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'status': status});
      }
    } catch (e) {
      throw Exception('Failed to update reading list entry: $e');
    }
  }

  // Delete a user's reading list entry in Firestore
  Future<void> deleteReadingListEntry({
    required String userId,
    required String bookId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('ReadingList')
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete reading list entry: $e');
    }
  }

  // Add a user review to Firestore
  Future<void> addReview({
    required String bookId,
    required AppUser user,
    required String title,
    required String content,
    required double rating,
  }) async {
    try {
      await _firestore.collection('Reviews').add({
        'bookId': bookId,
        'authorId': user.id,
        'author': user.displayName,
        'title': title,
        'content': content,
        'rating': rating,
        'time': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  // Get user by ID from Firestore
  Future<AppUser?> getUserById(String userId) async {
    try {
      final userDoc = await _firestore.collection('Users').doc(userId).get();
      if (userDoc.exists) {
        return AppUser.fromMap(userId, userDoc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get a reading list entry from Firestore
  Future<ReadingListEntry?> getReadingListEntry({
    required String userId,
    required String bookId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('ReadingList')
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ReadingListEntry.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch reading list entry: $e');
    }
  }

  // Get reviews for a book from Firestore
  Future<List<Review>> getBookReviews(String bookId) async {
    try {
      final querySnapshot = await _firestore
          .collection('Reviews')
          .where('bookId', isEqualTo: bookId)
          .orderBy('time')
          .get();

      return querySnapshot.docs
          .map((doc) => Review.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  // Get all genres from Firestore
  Future<List<String>> getGenres() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Genres').get();
      List<String> genres =
          snapshot.docs.map((doc) => doc['name'] as String).toList();
      return genres;
    } catch (e) {
      return [];
    }
  }

  // Get real-time stream of discussions
  Stream<List<Discussion>> getDiscussionsStream() {
    return _firestore.collection('Discussions').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Discussion.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Get real-time stream of Messages
  Stream<List<Message>> getMessagesStream(String discussionId) {
    return _firestore
        .collection('Messages')
        .where('discussionId', isEqualTo: discussionId)
        .orderBy('time')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Get real-time stream of reading list entries
  Stream<List<ReadingListEntry>> getReadingListStream(String userId) {
    return _firestore
        .collection('ReadingList')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReadingListEntry.fromMap(doc.data());
      }).toList();
    });
  }
}
