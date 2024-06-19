import 'dart:io';
import 'package:flutter/material.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:lanzoscan/label/labels.dart';
import 'package:lanzoscan/model/bbox.dart';

class ResultWidget extends StatelessWidget {
  final File? imageFile;
  final List<Widget> bboxesWidgets;
  final WidgetsToImageController controller;
  final bool isLoading;
  final List<int> classes;
  final List<double> scores;

  const ResultWidget({
    required this.imageFile,
    required this.bboxesWidgets,
    required this.controller,
    required this.isLoading,
    required this.classes,
    required this.scores,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetsToImage(
      controller: controller,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Center(
              child: SizedBox(
                height: 400,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageFile != null)
                          Image.file(
                            imageFile!,
                            fit: BoxFit.cover,
                          ),
                        ...bboxesWidgets,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: isLoading
                  ? const SizedBox()
                  : bboxesWidgets.isNotEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'RESULT: ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        labels[classes[0]]['name'].toString(),
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.amber[200],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          "${(scores[0] * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'DESCRIPTION: ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.amber[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      labels[classes[0]]['description'].toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: IconButton(
                      onPressed: () async {
                        final bytes = await controller.capture();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Image Result Saved')),
                        );
                      },
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
