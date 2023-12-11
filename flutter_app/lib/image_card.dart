import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:final_project/image_class.dart';
import 'package:final_project/image_detailed.dart';
import 'package:flutter/material.dart';
import 'package:final_project/models/ModelProvider.dart' as modelprovider;

class ImageCard extends StatelessWidget {
  const ImageCard(this.image, this.searchText, this.runCode, {super.key});

  final CustomImage image;
  final String searchText;
  final Function() runCode;

  Future<void> deleteImage() async {
    await removeImageData(image.amzImg);
    await removeImage(key: image.key, accessLevel: StorageAccessLevel.guest);
  }

  Future<void> removeImageData(modelprovider.Image image) async {
    final request = ModelMutations.delete(image);
    final response = await Amplify.API.mutate(request: request).response;
    safePrint('Response: $response');
  }

  Future<void> removeImage({
    required String key,
    required StorageAccessLevel accessLevel,
  }) async {
    try {
      final result = await Amplify.Storage.remove(
        key: key,
        options: StorageRemoveOptions(
          accessLevel: accessLevel,
        ),
      ).result;

      safePrint('Removed file: ${result.removedItem.key}');
    } on StorageException catch (e) {
      safePrint('Error deleting file: ${e.message}');

      rethrow;
    }
  }

  goToDetail(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.extended(
                    elevation: 1,
                    heroTag: "btn1",
                    onPressed: () => Navigator.pop(context),
                    label: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FloatingActionButton.extended(
                    elevation: 1,
                    heroTag: "btn2",
                    backgroundColor: colorScheme.errorContainer,
                    onPressed: () async {
                      await deleteImage();
                      if (context.mounted) Navigator.of(context).pop();
                      runCode();
                    },
                    label: Icon(
                      Icons.delete,
                      color: colorScheme.error,
                    ),
                  )
                ],
              ),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Name: ${image.key}"),
                      Text("Colorspace: ${image.image.colorSpace.name}"),
                      Text(
                          "Resolution: ${image.image.width}x${image.image.height}"),
                      Text("Uploaded by: ${image.username}"),
                      Text("Upload Date: ${image.formattedDate()}")
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: ImageDetailed(image),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget photo = ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.memory(
        image.imageBytes,
        height: 170,
      ),
    );

    Widget tags = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...image.tags.map((tag) {
          bool tagMatch =
              tag.toLowerCase().contains(searchText.toLowerCase()) &&
                  searchText != "";
          return TagCard(tag, tagMatch);
        })
      ],
    );

    List<Widget> userdate = [
      Text("By: ${image.username}"),
      Text(image.formattedDate())
    ];

    return SizedBox(
      height: 300,
      width: 300,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () => goToDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [Center(child: photo), tags, ...userdate],
            ),
          ),
        ),
      ),
    );
  }
}

class TagCard extends StatelessWidget {
  const TagCard(this.tag, this.match, {super.key});

  final String tag;
  final bool match;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: match
          ? Colors.green
          : Theme.of(context).colorScheme.tertiaryContainer,
      elevation: 2,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(tag)),
    );
  }
}
