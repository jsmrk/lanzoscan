import 'package:flutter/material.dart';
import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';

class LanzoScanWiki extends StatelessWidget {
  static const headerStyle =
      TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold);
  static const contentStyleHeader =
      TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700);
  static const contentStyle = TextStyle(
      color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal);
  const LanzoScanWiki({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Wiki'),
          elevation: 1,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.scaleDown,
                    height: 125,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 5, left: 25, right: 25),
                child: Text(
                  "Lanzones trees can suffer from leaf diseases such as algal leaf spot, leaf blight, and powdery mildew. These cause brown spots, early leaf drop, and stunted growth. To protect your crop and ensure a good harvest, use early detection, fungicides, good sanitation, and proper irrigation.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Accordion(
                  headerBackgroundColor: Colors.amber[100],
                  headerBackgroundColorOpened: Colors.amber[200],
                  contentBackgroundColor: Colors.white,
                  contentBorderColor: Colors.amber[200],
                  contentBorderWidth: 2,
                  contentHorizontalPadding: 25,
                  scaleWhenAnimating: false,
                  openAndCloseAnimation: true,
                  paddingListHorizontal: 15,
                  rightIcon: const Icon(
                    Icons.arrow_drop_down_sharp,
                    size: 35,
                  ),
                  headerPadding:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
                  sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
                  sectionClosingHapticFeedback: SectionHapticFeedback.light,
                  children: [
                    AccordionSection(
                      isOpen: false,
                      contentVerticalPadding: 20,
                      header: const Text('Algal Leaf Spot', style: headerStyle),
                      content: const Column(
                        children: [
                          Text(
                            'Algal leaf spot causes small, round, chlorotic spots that turn brown or reddish-brown on Lanzones leaves. It thrives in humid conditions.',
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Text(
                                'What to Do:',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Text(
                            '- Identify and isolate infected trees.\n'
                            '- Improve growing conditions: proper irrigation, avoid overhead watering, ensure good drainage.\n'
                            '- Manage using copper-based fungicides (follow application guidelines).\n'
                            '- Consider biological control with Pseudomonas fluorescens (research ongoing).\n'
                            '- Remove fallen leaves and debris.\n'
                            '- Prune infected leaves and branches for better air circulation.\n'
                            '- Consult your local agricultural extension office for specific recommendations.',
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                    AccordionSection(
                      isOpen: false,
                      contentVerticalPadding: 20,
                      header: const Text('Leaf Blight', style: headerStyle),
                      content: const Column(
                        children: [
                          Text(
                            'Leaf blight manifests as large, irregular, water-soaked lesions that turn brown or grayish-black. It can cause premature leaf drop, reducing fruit yield.',
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Text(
                                'What to Do:',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Text(
                            '- Use copper-based fungicides as a preventative measure.\n'
                            '- Prune infected leaves and branches to minimize spread.\n'
                            '- Maintain good orchard sanitation (remove fallen leaves and debris).\n'
                            '- Ensure proper fertilization for overall plant health.\n'
                            '- Consult your local agricultural extension office for tailored advice.',
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                    AccordionSection(
                      isOpen: false,
                      contentVerticalPadding: 20,
                      header: const Text('Powdery Mildew', style: headerStyle),
                      content: const Column(
                        children: [
                          Text(
                            'Powdery mildew appears as white or grayish powdery patches on the upper surface of Lanzones leaves. It stunts leaf growth and reduces fruit quality.',
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Text(
                                'What to Do:',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Text(
                            '- Apply sulfur-based fungicides as a preventative measure.\n'
                            '- Ensure proper air circulation within the orchard (avoid dense planting).\n'
                            '- Water at the base of the tree to avoid wetting the leaves.\n'
                            '- Control weeds that compete with trees for nutrients and air circulation.\n'
                            '- Consult your local agricultural extension office for specific recommendations.',
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                  ]),
            ],
          ),
        ));
  }
}
