import 'package:flutter/material.dart';
import 'package:novel_nest/models/discussion.dart';
import 'package:novel_nest/services/auth_service.dart';
import 'package:novel_nest/services/firestore_service.dart';
import 'package:provider/provider.dart';

class DiscussionDialog extends StatefulWidget {
  final Discussion? editDiscussion;

  const DiscussionDialog({super.key, this.editDiscussion});

  @override
  State<DiscussionDialog> createState() => _DiscussionDialogState();
}

class _DiscussionDialogState extends State<DiscussionDialog> {
  late final TextEditingController _titleController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.editDiscussion?.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String? _titleValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a title';
    }
    return null;
  }

  void _submit() async {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final currentUser = await authService.getCurrentUser();
    final title = _titleController.text.trim();

    if ((_formKey.currentState?.validate() ?? false) && currentUser != null) {
      if (widget.editDiscussion == null) {
        await firestoreService.addDiscussion(
          title: title,
          author: currentUser,
        );
      } else if (title != widget.editDiscussion!.title) {
        await firestoreService.updateDiscussion(
          discussionId: widget.editDiscussion!.id,
          title: _titleController.text.trim(),
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _delete() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this discussion?'),
        backgroundColor: const Color(0xFFF5F5F5),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.red),
              foregroundColor: WidgetStatePropertyAll(Colors.white),
            ),
            onPressed: () async {
              final firestoreService = context.read<FirestoreService>();
              await firestoreService
                  .deleteDiscussion(widget.editDiscussion!.id);
              if (context.mounted) {
                // Closes the confirm and edit dialogs
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editDiscussion == null
          ? 'Create Discussion'
          : 'Edit Discussion'),
      backgroundColor: const Color(0xFFF5F5F5),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
            fillColor: Colors.white,
            filled: true,
          ),
          maxLength: 100,
          validator: _titleValidator,
        ),
      ),
      actions: [
        if (widget.editDiscussion != null)
          TextButton(
            onPressed: _delete,
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.red),
              foregroundColor: WidgetStatePropertyAll(Colors.white),
            ),
            child: const Text('Delete'),
          ),
        if (widget.editDiscussion == null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.editDiscussion == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}
