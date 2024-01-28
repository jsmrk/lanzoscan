import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

enum Choice { camera, gallery }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  ValueNotifier<bool> expandedValue = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            onPressed: () {},
            icon: const Icon(
              Icons.question_mark_rounded,
            ),
          ),
        ],
      ),
      body: Center(
        child: Image.asset(
          'assets/images/noimage.png',
          height: 255,
          fit: BoxFit.scaleDown,
        ),
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  Widget _buildFloatingButton() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      openCloseDial: expandedValue,
      onOpen: () => setState(() => expandedValue.value = true),
      onClose: () => setState(() => expandedValue.value = false),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.camera_alt),
          label: 'Camera',
          onTap: () => print('Camera option tapped!'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.photo_library),
          label: 'Gallery',
          onTap: () => print('Gallery option tapped!'),
        ),
      ],
    );
  }
}
