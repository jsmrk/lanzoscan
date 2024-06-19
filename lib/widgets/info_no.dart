import 'package:flutter/material.dart';

class InfoNo extends StatelessWidget {
  const InfoNo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20), // Circular border radius
              child: Container(

                child: Image.asset(
                  'assets/images/lanzologo.png', // Replace with your image path in your assets folder
                  width: 100, // Adjust width as needed
                  height: 100, // Adjust height as needed
                  fit: BoxFit.cover, // Adjust how the image fits within the box
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Title Attach',
                        style: Theme.of(context).textTheme.titleMedium
                    ),
                    Text(
                      '11:00 PM',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Text(
                  'Description Attach',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    height: 1.5, // Removed extra parentheses
                  ),
                ),
                SizedBox(height: 8), // Added SizedBox for spacing

              ],
            ),
          ),
        ],
      ),
    );
  }
}
