import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:lanzoscan/bbox.dart';
import 'package:lanzoscan/labels.dart';
import 'package:lanzoscan/yolo.dart';

enum Choice { camera, gallery }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  ValueNotifier<bool> expandedValue = ValueNotifier(false);

  static const inModelWidth = 640;
  static const inModelHeight = 640;
  static const numClasses = 4;

  double confidenceThreshold = 0.4;
  double iouThreshold = 0.1;

  File? imageFile;
  final ImagePicker picker = ImagePicker();

  List<List<double>>? inferenceOutput;
  List<int> classes = [];
  List<List<double>> bboxes = [];
  List<double> scores = [];

  int? imageWidth;
  int? imageHeight;

  static const double maxImageWidgetHeight = 400;

  final YoloModel model = YoloModel(
    'assets/models/yolov8n.tflite',
    inModelWidth,
    inModelHeight,
    numClasses,
  );

  // Widget displaySelectedImages() {
  //   return Container(
  //     height: 325,
  //     width: 335,
  //     child: imageFile != null
  //         ? ClipRRect(
  //             borderRadius: const BorderRadius.all(Radius.circular(15)),
  //             child: Image.file(imageFile!, fit: BoxFit.cover),
  //           )
  //         : const Center(child: Icon(Icons.image_rounded)),
  //   );
  // }

  Future<File?> getImageFromGallery() async {
    final XFile? newImageFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (newImageFile != null) {
      setState(() {
        imageFile = File(newImageFile.path);
      });
      final image = img.decodeImage(await newImageFile.readAsBytes())!;
      imageWidth = image.width;
      imageHeight = image.height;
      inferenceOutput = model.infer(image);
      updatePostprocess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
      return null;
    }
  }

  Future<File?> getImageFromCamera() async {
    final XFile? newImageFile =
        await picker.pickImage(source: ImageSource.camera);
    if (newImageFile != null) {
      setState(() {
        imageFile = File(newImageFile.path);
      });
      final image = img.decodeImage(await newImageFile.readAsBytes())!;
      imageWidth = image.width;
      imageHeight = image.height;
      inferenceOutput = model.infer(image);
      updatePostprocess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    model.init();
  }

  @override
  Widget build(BuildContext context) {
    final bboxesColors = List<Color>.generate(
      numClasses,
      (_) => Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
    );

    // final ImagePicker picker = ImagePicker();

    final double displayWidth = MediaQuery.of(context).size.width;

    double resizeFactor = 1;

    if (imageWidth != null && imageHeight != null) {
      double k1 = displayWidth / imageWidth!;
      double k2 = maxImageWidgetHeight / imageHeight!;
      resizeFactor = min(k1, k2);
    }

    List<Bbox> bboxesWidgets = [];
    for (int i = 0; i < bboxes.length; i++) {
      final box = bboxes[i];
      final boxClass = classes[i];
      bboxesWidgets.add(
        Bbox(
            box[0] * resizeFactor,
            box[1] * resizeFactor,
            box[2] * resizeFactor,
            box[3] * resizeFactor,
            labels[boxClass],
            scores[i],
            bboxesColors[boxClass]),
      );
    }

    return Scaffold(
      appBar: imageFile == null
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
      body: imageFile != null
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
                  child: Center(
                    child: SizedBox(
                      height: maxImageWidgetHeight,
                      child: Center(
                        child: Stack(
                          children: [
                            if (imageFile != null) Image.file(imageFile!),
                            ...bboxesWidgets,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
              ],
            )
          : Center(
              child: Image.asset(
                'assets/images/noimage.png',
                height: 255,
                fit: BoxFit.scaleDown,
              ),
            ),
      floatingActionButton: imageFile != null ? null : _buildFloatingButton(),
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

  void updatePostprocess() {
    if (inferenceOutput == null) {
      return;
    }
    List<int> newClasses = [];
    List<List<double>> newBboxes = [];
    List<double> newScores = [];
    (newClasses, newBboxes, newScores) = model.postprocess(
      inferenceOutput!,
      imageWidth!,
      imageHeight!,
      confidenceThreshold: confidenceThreshold,
      iouThreshold: iouThreshold,
    );
    debugPrint('Detected ${bboxes.length} bboxes');
    setState(() {
      classes = newClasses;
      bboxes = newBboxes;
      scores = newScores;
    });
  }
}
