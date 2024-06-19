import 'package:flutter/material.dart';
import 'package:lanzoscan/pages/library.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shadowColor: Colors.black,
      elevation: 1,
      leading: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Image.asset(
          'assets/images/logo2.png',
          fit: BoxFit.scaleDown,
        ),
      ),
      leadingWidth: 185,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LanzoScanWiki()),
            );
          },
          icon: const Icon(
            Icons.menu_book_rounded,
            size: 30,
          ),
        ),
      ],
    );
  }
}
