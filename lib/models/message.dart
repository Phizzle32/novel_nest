import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String content;
  final String discussionId;
  final DateTime time;
  final String userId;
  final String username;

  Message({
    required this.id,
    required this.content,
    required this.discussionId,
    required this.time,
    required this.userId,
    required this.username,
  });

  factory Message.fromMap(String id, Map<String, dynamic> data) {
    return Message(
      id: id,
      content: data['content'] ?? '',
      discussionId: data['discussionId'] ?? '',
      time: (data['time'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'discussionId': discussionId,
      'time': time.toIso8601String(),
      'userId': userId,
      'username': username,
    };
  }
}