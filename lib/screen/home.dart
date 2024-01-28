import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

enum Choice { camera, gallery }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 251, 242, 155),
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
            onPressed: () {},
            icon: const Icon(
              Icons.question_mark,
            ),
          ),
        ],
      ),
    );
  }
}
