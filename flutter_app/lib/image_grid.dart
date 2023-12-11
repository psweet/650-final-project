import 'package:final_project/image_class.dart';
import 'package:final_project/image_card.dart';
import 'package:flutter/material.dart';

class ImageGrid extends StatelessWidget {
  const ImageGrid(this.searchText, this.runCode,
      {required this.images, super.key});

  final String searchText;
  final List<CustomImage> images;
  final Function() runCode;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...images.map((image) => ImageCard(image, searchText, runCode))
          ],
        ),
      ),
    );
  }
}
