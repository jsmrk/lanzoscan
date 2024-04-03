import 'dart:io';

import 'package:flutter/material.dart';
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
    return Container(
      height: 325,
      width: 335,
      child: selectedImage != null
          ? ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              child: Image.file(selectedImage!, fit: BoxFit.cover),
            )
          : const Center(child: Icon(Icons.image_rounded)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: selectedImage == null
          ? AppBar(
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
            )
          : null,
      body: selectedImage != null
          ? Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 105),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.scaleDown,
                    height: 125,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  alignment: Alignment.topCenter,
                  child: displaySelectedImages(),
                ),
                const SizedBox(
                  height: 25,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Scan Now',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )
          : Center(
              child: Image.asset(
                'assets/images/noimage.png',
                height: 255,
                fit: BoxFit.scaleDown,
              ),
            ),
      floatingActionButton:
          selectedImage != null ? null : _buildFloatingButton(),
    );
  }

  Widget _buildFloatingButton() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      openCloseDial: expandedValue,
      buttonSize: const Size(65, 65),
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
