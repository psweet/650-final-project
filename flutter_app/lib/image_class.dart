import 'dart:typed_data';
import 'dart:ui' as d;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_project/models/ModelProvider.dart' as modelprovider;

class CustomImage {
  String key;
  DateTime dateUploaded;
  String username;
  List<String> tags;
  modelprovider.Image amzImg;

  late Uint8List imageBytes;
  late d.Image image;

  CustomImage(
      this.key, this.dateUploaded, this.username, this.tags, this.amzImg);

  Future<void> downloadImage() async {
    try {
      final result = await Amplify.Storage.downloadData(
        key: key,
        onProgress: (progress) {
          safePrint('Fraction completed: ${progress.fractionCompleted}');
        },
      ).result;
      imageBytes = Uint8List.fromList(result.bytes);

      image = await decodeImageFromList(imageBytes);
    } on StorageException catch (e) {
      safePrint(e.message);
    }
  }

  String formattedDate() {
    return DateFormat("M/d/yy").format(dateUploaded);
  }

  static Future<CustomImage> fromImage(modelprovider.Image img) async {
    var finalImg = CustomImage(
        img.key, img.uploadDate.getDateTime(), img.owner, img.tags ?? [], img);
    await finalImg.downloadImage();

    return finalImg;
  }
}
