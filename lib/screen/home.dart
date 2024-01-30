import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';

enum Choice { camera, gallery }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  ValueNotifier<bool> expandedValue = ValueNotifier(false);

  final picker = ImagePicker();
  int _currentImageIndex = 0;

  File? selectedImage;

  Future<File?> getImageFromGallery() async {
    final pickedFile = await picker.pickImage(
      imageQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      setState(() {});
      return selectedImage;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
      return null;
    }
  }

  Future<File?> getImageFromCamera() async {
    final pickedFile = await picker.pickImage(
      imageQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      setState(() {});
      return selectedImage;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
      return null;
    }
  }

  Widget displaySelectedImages() {
    return SizedBox(
      height: 225,
      width: 365,
      child: selectedImage != null // Check for a selected image
          ? ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              child: Image.file(selectedImage!, fit: BoxFit.cover),
            )
          : const Center(
              child: Icon(Icons.image_rounded)), // Display placeholder
    );
  }

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
      body: selectedImage != null
          ? displaySelectedImages()
          : Center(
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
          onTap: getImageFromCamera,
        ),
        SpeedDialChild(
          child: const Icon(Icons.photo_library),
          label: 'Gallery',
          onTap: getImageFromGallery,
        ),
      ],
    );
  }
}
