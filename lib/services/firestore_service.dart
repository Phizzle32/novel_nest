import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:novel_nest/models/app_user.dart';
import 'package:novel_nest/models/discussion.dart';
import 'package:novel_nest/models/message.dart';

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
        _updateUserMessages(user.id, displayName);
      }
      if (preferredGenres != null &&
          preferredGenres != user.preferredGenres) {
        updates['preferredGenres'] = preferredGenres;
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('Users').doc(user.id).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> _updateUserMessages(String userId, String newName) async {
    final messagesRef = _firestore.collection('Messages');
    final userMessages =
        await messagesRef.where('userId', isEqualTo: userId).get();

    final batch = _firestore.batch();

    for (var doc in userMessages.docs) {
      batch.update(doc.reference, {'username': newName});
    }

    await batch.commit();
  }

  // Delete user from Firestore
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('Users').doc(userId).delete();
      // TODO: delete the user's reading list as well
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
}
