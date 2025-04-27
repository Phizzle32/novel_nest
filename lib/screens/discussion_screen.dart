import 'package:flutter/material.dart';
import 'package:novel_nest/models/app_user.dart';
import 'package:novel_nest/models/discussion.dart';
import 'package:novel_nest/models/message.dart';
import 'package:novel_nest/services/auth_service.dart';
import 'package:novel_nest/services/firestore_service.dart';
import 'package:novel_nest/widgets/novel_nest_app_bar.dart';
import 'package:novel_nest/widgets/novel_nest_drawer.dart';
import 'package:provider/provider.dart';

class DiscussionScreen extends StatefulWidget {
  final Discussion discussion;

  const DiscussionScreen({super.key, required this.discussion});

  @override
  State<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final authService = context.read<AuthService>();
    final user = await authService.getCurrentUser();
    setState(() {
      currentUser = user;
    });
  }

  Stream<List<Message>> _getMessages() {
    final firestoreService = context.read<FirestoreService>();
    return firestoreService.getMessagesStream(widget.discussion.id);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty && currentUser != null) {
      final firestoreService = context.read<FirestoreService>();
      firestoreService.addMessage(
        content: _messageController.text,
        discussionId: widget.discussion.id,
        author: currentUser!,
      );
    }
    _messageController.clear();
  }

  BoxDecoration _getMessageDisplay(String userId) {
    return BoxDecoration(
      color: userId == currentUser?.id
          ? const Color(0xFFDAE8FC)
          : const Color(0xFFE1D5E7),
      border: Border.all(
        color: userId == currentUser?.id
            ? const Color(0xFF6C8EBF)
            : const Color(0xFF9673A6),
      ),
      borderRadius: BorderRadius.circular(8),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: NovelNestAppBar(
        title: widget.discussion.title,
        showBackButton: true,
      ),
      drawer: const NovelNestDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFC4DDE9),
              const Color(0xFFDFD5E7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: _getMessages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load messages'));
                  }
                  final messages = snapshot.data ?? [];
                  if (messages.isEmpty) {
                    return const Center(child: Text('No messages available'));
                  }

                  // Scrolls to the bottom on initial load and after new message arrives
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  return ListView.builder(
                    itemCount: messages.length,
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return Container(
                        margin: const EdgeInsets.all(8),
                        decoration: _getMessageDisplay(message.userId),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                message.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                message.time.toLocal().toString().split('.')[0],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(message.content),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLength: 500,
                      decoration: InputDecoration(
                        labelText: 'Enter your message',
                        counterText: '',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
