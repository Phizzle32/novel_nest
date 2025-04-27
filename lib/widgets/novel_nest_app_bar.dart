import 'package:flutter/material.dart';

class NovelNestAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;

  const NovelNestAppBar({
    super.key,
    this.title,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFEFE4DA),
      title: title != null
          ? Text(title!)
          : const Image(
              image: AssetImage('assets/logo.png'),
              height: 50,
            ),
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            )
          : IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu),
            ),
      shape: const Border(
        bottom: BorderSide(color: Colors.blueGrey, width: 1.5),
      ),
    );
  }
}
