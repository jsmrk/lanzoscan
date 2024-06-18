import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:lanzoscan/model/bbox.dart';
import 'package:lanzoscan/label/labels.dart';
import 'package:lanzoscan/model/yolo.dart';
import 'package:lanzoscan/pages/library.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gal/gal.dart';

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
  // to save image bytes of widget
  Uint8List? bytes;

  Widget buildImage(Uint8List bytes) => Image.memory(bytes);

  late ValueNotifier<double> valueNotifier;

  final YoloModel model = YoloModel(
    'assets/models/yolov8n.tflite',
    inModelWidth,
    inModelHeight,
    numClasses,
  );

  Future<void> showDelayedLoading() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  Future<File?> getImageFromGallery() async {
    final XFile? newImageFile =
        await picker.pickImage(source: ImageSource.gallery);
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
      // setState(() {
      //   isLoading = false;
      // });
      showDelayedLoading();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
    return null;
  }

  Future<File?> getImageFromCamera() async {
    final XFile? newImageFile =
        await picker.pickImage(source: ImageSource.camera);
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
      // setState(() {
      //   isLoading = false;
      // });
      showDelayedLoading();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
    return null;
  }

  // Future<Uint8List> scanResult() async {
  //   Uint8List? bytes;
  //   final bytes = await controller.capture();
  //   setState(() {
  //     this.bytes = bytes;
  //   });
  // }

  final bboxesColors = List<Color>.generate(
    numClasses,
    (_) => Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
  );

  @override
  void initState() {
    super.initState();
    model.init();
    valueNotifier = ValueNotifier(0.0);
  }

  @override
  Widget build(BuildContext context) {
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
            scores[i],
            bboxesColors[boxClass]),
      );
    }

    WidgetsToImageController controller = WidgetsToImageController();
    // to save image bytes of widget

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
      ),
      body: Stack(
        children: [
          imageFile != null
              ? Column(
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    WidgetsToImage(
                      controller: controller,
                      child: resultWidget(bboxesWidgets),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          splashColor: Colors.transparent,
                          enableFeedback: false,
                          isSelected: false,
                          hoverColor: Colors.transparent,
                          focusNode: FocusNode(),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LanzoScanWiki()),
                            );
                          },
                          icon: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: const BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.book),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("More Details")
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final bytes = await controller.capture();
                            setState(() {
                              this.bytes = bytes;
                            });
                            await Gal.putImageBytes(bytes!);
                            buildImage(bytes);
                            isResultSaved = true;
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Image Result Saved')));
                          },
                          icon: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.amber[100],
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15))),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("Save to Gallery")
                              ],
                            ),
                          ),
                        )
                      ],
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
          Visibility(
            visible: isLoading, // Show loading indicator when loading
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.scaleDown,
                      height: 125,
                    ),
                  ),
                  const Text(
                    'is now scanning',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const SpinKitPouringHourGlassRefined(color: Colors.amber),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  Widget resultWidget(List<Widget> bboxesWidgets) {
    return WidgetsToImage(
      controller: controller,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Center(
              child: SizedBox(
                height: maxImageWidgetHeight,
                child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: ClipRRect(
                      borderRadius: BorderRadiusDirectional.circular(25),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        // fit: StackFit.expand,

                        children: [
                          if (imageFile != null)
                            Image.file(
                              imageFile!,
                              // fit: BoxFit.cover,
                            ),
                          ...bboxesWidgets,
                        ],
                      ),
                    )),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: isLoading
                  ? const SizedBox()
                  : bboxesWidgets.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Scan Result:',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      labels[classes[0]]['name'].toString(),
                                      style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 35),
                                SimpleCircularProgressBar(
                                  valueNotifier: valueNotifier,
                                  mergeMode: true,
                                  animationDuration: 2,
                                  maxValue: 100,
                                  size: 70,
                                  progressStrokeWidth: 13,
                                  backStrokeWidth: 13,
                                  progressColors: const [
                                    Color.fromARGB(255, 255, 238, 190),
                                    Colors.amber
                                  ],
                                  onGetText: (double value) {
                                    TextStyle centerTextStyle = const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black
                                        // .withOpacity(value * 0.01),
                                        );
                                    return Text(
                                      '${value.toInt()}%',
                                      style: centerTextStyle,
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            IconButton(
                              splashColor: Colors.transparent,
                              enableFeedback: false,
                              isSelected: false,
                              hoverColor: Colors.transparent,
                              focusNode: FocusNode(),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LanzoScanWiki()),
                                );
                              },
                              icon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        labels[classes[0]]['description']
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                    ],
                                  )),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        )
                      : const SizedBox(), // Display an empty SizedBox if no labels detected
            )
          ],
        ),
      ),
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
    valueNotifier.value = (scores[0] * 100).toDouble();
  }

  @override
  void dispose() {
    valueNotifier.dispose();
    super.dispose();
  }
}
