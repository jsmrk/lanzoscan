import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:lanzoscan/model/yolo.dart';
import 'package:lanzoscan/model/bbox.dart';
import 'package:lanzoscan/widgets/components/appbar_widget.dart';
import 'package:lanzoscan/widgets/components/floatingbutton.dart';
import 'package:lanzoscan/widgets/components/loading_overlay.dart';
import 'package:lanzoscan/widgets/components/result_widgets.dart';

enum Choice { camera, gallery }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  ValueNotifier<bool> expandedValue = ValueNotifier(false);
  bool isLoading = false;
  bool isResultSaved = false;
  static const inModelWidth = 640;
  static const inModelHeight = 640;
  static const numClasses = 4;
  double confidenceThreshold = 0.25;
  double iouThreshold = 0.45;
  File? imageFile;
  final ImagePicker picker = ImagePicker();
  List<List<double>>? inferenceOutput;
  List<int> classes = [];
  List<List<double>> bboxes = [];
  List<double> scores = [];
  int? imageWidth;
  int? imageHeight;
  static const double maxImageWidgetHeight = 400;
  WidgetsToImageController controller = WidgetsToImageController();
  Uint8List? bytes;
  Widget buildImage(Uint8List bytes) => Image.memory(bytes);
  final RoundedLoadingButtonController btnController = RoundedLoadingButtonController();
  final YoloModel model = YoloModel(
    'assets/models/yolov8n.tflite',
    inModelWidth,
    inModelHeight,
    numClasses,
  );
  final bboxesColors = List<Color>.generate(
    numClasses,
        (_) => Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
  );

  Future<void> showDelayedLoading() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  Future<File?> getImageFromGallery() async {
    final XFile? newImageFile = await picker.pickImage(source: ImageSource.gallery);
    if (newImageFile != null) {
      setState(() {
        imageFile = File(newImageFile.path);
        isLoading = true;
      });
      final image = img.decodeImage(await newImageFile.readAsBytes())!;
      imageWidth = image.width;
      imageHeight = image.height;
      inferenceOutput = model.infer(image);
      updatePostprocess();
      showDelayedLoading();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
    return null;
  }

  Future<File?> getImageFromCamera() async {
    final XFile? newImageFile = await picker.pickImage(source: ImageSource.camera);
    if (newImageFile != null) {
      setState(() {
        imageFile = File(newImageFile.path);
        isLoading = true;
      });
      final image = img.decodeImage(await newImageFile.readAsBytes())!;
      imageWidth = image.width;
      imageHeight = image.height;
      inferenceOutput = model.infer(image);
      updatePostprocess();
      showDelayedLoading();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    model.init();
  }

  @override
  Widget build(BuildContext context) {
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
          scores[i],
          bboxesColors[boxClass],
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          imageFile != null
              ? ResultWidget(
            imageFile: imageFile,
            bboxesWidgets: bboxesWidgets,
            controller: controller,
            isLoading: isLoading,
            classes: classes,
            scores: scores,
          )
              : Center(
            child: Image.asset(
              'assets/images/noimage.png',
              height: 255,
              fit: BoxFit.scaleDown,
            ),
          ),
          LoadingOverlay(isLoading: isLoading),
        ],
      ),
      floatingActionButton: FloatingButton(
        expandedValue: expandedValue,
        getImageFromCamera: getImageFromCamera,
        getImageFromGallery: getImageFromGallery,
      ),
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
