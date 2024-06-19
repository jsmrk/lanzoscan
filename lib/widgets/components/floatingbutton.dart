import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class FloatingButton extends StatelessWidget {
  final ValueNotifier<bool> expandedValue;
  final Future<void> Function() getImageFromCamera;
  final Future<void> Function() getImageFromGallery;

  const FloatingButton({
    required this.expandedValue,
    required this.getImageFromCamera,
    required this.getImageFromGallery,
  });

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      openCloseDial: expandedValue,
      buttonSize: const Size(65, 65),
      onOpen: () => expandedValue.value = true,
      onClose: () => expandedValue.value = false,
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
