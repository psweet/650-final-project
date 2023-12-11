import 'package:final_project/image_class.dart';
import 'package:flutter/material.dart';

class ImageDetailed extends StatelessWidget {
  const ImageDetailed(this.image, {super.key});

  final CustomImage image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Center(
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                floatingActionButton: FloatingActionButton.extended(
                  elevation: 1,
                  heroTag: "btn3",
                  onPressed: () => Navigator.pop(context),
                  label: const Icon(Icons.arrow_back),
                ),
                body: ListView(
                  children: [
                    Image.memory(
                      image.imageBytes,
                    ),
                  ],
                ),
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.memory(
              image.imageBytes,
            ),
          ),
        ),
      ),
    );
  }
}
