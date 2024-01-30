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
  List<File> selectedImages = [];

  Future<File?> getImageFromGallery() async {
    final pickedFile = await picker.pickImage(
      imageQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
      source: ImageSource.gallery, // Specify source as gallery (or camera)
    );

    if (pickedFile != null) {
      selectedImages
          .add(File(pickedFile.path)); // Add the single image to the list
      setState(() {}); // Trigger UI update
      return selectedImages[0]; // Return the selected image
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
      child: selectedImages.isEmpty
          ? const Center(child: Icon(Icons.image_rounded))
          : Stack(
              children: [
                // PageView for sliding images
                PageView.builder(
                  itemCount: selectedImages.length,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (int newPageIndex) {
                    setState(() {
                      _currentImageIndex = newPageIndex;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        child: kIsWeb
                            ? ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                child: Image.network(
                                  selectedImages[index].path,
                                  fit: BoxFit.cover,
                                ))
                            : ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                child: Image.file(selectedImages[index],
                                    fit: BoxFit.cover),
                              ));
                  },
                ),

                // Dots for multiple images
                if (selectedImages.length > 1)
                  Positioned(
                    bottom: 11,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        selectedImages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == _currentImageIndex
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
      body: selectedImages.isNotEmpty
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
          onTap: null,
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
