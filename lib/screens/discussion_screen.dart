import 'package:flutter/material.dart';
import 'package:novel_nest/models/discussion.dart';
import 'package:novel_nest/widgets/novel_nest_app_bar.dart';
import 'package:novel_nest/widgets/novel_nest_drawer.dart';

class DiscussionScreen extends StatefulWidget {
  final Discussion discussion;

  const DiscussionScreen({super.key, required this.discussion});

  @override
  State<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NovelNestAppBar(
        title: widget.discussion.title,
        showBackButton: true,
      ),
      drawer: const NovelNestDrawer(),
    );
  }
}
