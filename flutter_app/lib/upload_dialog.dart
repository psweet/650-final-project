import 'dart:typed_data';
import 'dart:ui' as d;

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:final_project/models/ModelProvider.dart' as modelprovider;

class UploadDialog extends StatefulWidget {
  const UploadDialog(
      {required this.existingTags, required this.runCode, super.key});

  final Function() runCode;

  final Set<String> existingTags;

  @override
  State<UploadDialog> createState() => _UploadDialog();
}

class _UploadDialog extends State<UploadDialog> {
  bool uploadingLocally = false;

  Uint8List? imageBytes;
  String fileName = "Select a file";
  String userName = "";
  Set<String> tags = {};

  void uploading() {
    setState(() {
      uploadingLocally = !uploadingLocally;
    });
  }

  void updateFileName(String newName) {
    setState(() {
      fileName = newName;
    });
  }

  getFile() async {
    FilePickerResult? selected = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png']);

    if (selected != null) {
      uploading();
      imageBytes = selected.files.first.bytes;
      updateFileName(selected.files.first.name);
      uploading();
    }
  }

  Future<void> uploadImage(Uint8List bytes, String filename) async {
    try {
      final result = await Amplify.Storage.uploadData(
        data: S3DataPayload.bytes(bytes),
        key: filename,
        onProgress: (progress) {
          safePrint('Transferred bytes: ${progress.transferredBytes}');
        },
      ).result;

      safePrint('Uploaded data to location: ${result.uploadedItem.key}');
    } on StorageException catch (e) {
      safePrint(e.message);
    }
  }

  Future<void> submitForm() async {
    if (imageBytes == null) {
      return;
    }

    d.Image image = await decodeImageFromList(imageBytes!);

    await uploadImage(imageBytes!, fileName);

    final newEntry = modelprovider.Image(
        key: fileName,
        resolution: "${image.width}x${image.height}",
        owner: userName,
        uploadDate: TemporalDate.now(),
        colorspace: image.colorSpace.name,
        tags: tags.toList());

    final request = ModelMutations.create(newEntry);

    final _ = await Amplify.API.mutate(request: request).response;
  }

  Future<bool> sendToAWS() async {
    uploading();
    await submitForm();
    uploading();
    widget.runCode();
    return true;
  }

  addTag(String newTag) {
    setState(() {
      tags.add(newTag);
    });
  }

  removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }

  updateUsername(String newName) {
    setState(() {
      userName = newName;
    });
  }

  tagger() {
    if (tagsController.text.isNotEmpty) {
      addTag(tagsController.text);
    }

    tagsController.clear();
    focusNode.requestFocus();
  }

  final tagsController = SearchController();
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    Widget form = SizedBox(
      height: imageBytes == null ? 60 : 400,
      width: imageBytes == null ? 400 : 800,
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextButton(
                          onPressed: getFile,
                          child: Row(
                            children: [
                              Text(fileName),
                              const Spacer(),
                              const Icon(Icons.upload_file)
                            ],
                          )),
                    ),
                    if (imageBytes != null) ...[
                      TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                        ),
                        onChanged: (value) => updateUsername(value),
                      ),
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text("Tags:"),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ...tags.map(
                              (e) => Chip(
                                label: Text(e),
                                onDeleted: () => removeTag(e),
                              ),
                            )
                          ],
                        )
                      ],
                      const SizedBox(height: 10),
                      SearchAnchor(
                        searchController: tagsController,
                        builder: (context, controller) {
                          return SearchBar(
                            hintText: "Add tags",
                            elevation: const MaterialStatePropertyAll(1),
                            trailing: [
                              IconButton(
                                color: Colors.green,
                                onPressed:
                                    tagsController.text.isEmpty ? null : tagger,
                                icon: const Icon(Icons.check),
                              )
                            ],
                            controller: controller,
                            focusNode: focusNode,
                            onTap: () {
                              controller.openView();
                            },
                            onChanged: (_) {
                              controller.openView();
                            },
                            onSubmitted: (value) {
                              tagger();
                            },
                          );
                        },
                        suggestionsBuilder: (context, controller) {
                          return [
                            if (tagsController.text.isNotEmpty)
                              ListTile(
                                title: Text(tagsController.text),
                                onTap: () {
                                  setState(() {
                                    controller.closeView(tagsController.text);
                                    tagger();
                                  });
                                },
                              ),
                            ...widget.existingTags.where((String option) {
                              return option
                                  .toLowerCase()
                                  .contains(controller.text.toLowerCase());
                            }).map(
                              (e) => ListTile(
                                title: Text(e),
                                onTap: () {
                                  setState(() {
                                    controller.closeView(e);
                                    tagger();
                                  });
                                },
                              ),
                            )
                          ];
                        },
                      ),
                    ],
                    if (uploadingLocally)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: LinearProgressIndicator(),
                      )
                  ],
                ),
              ),
              if (imageBytes != null) ...[
                const SizedBox(width: 20),
                Image.memory(
                  imageBytes!,
                  height: 400,
                )
              ]
            ],
          ),
          if (uploadingLocally)
            Container(
              color: Colors.transparent,
              child: null,
            ),
        ],
      ),
    );

    bool uploadAvailable = !uploadingLocally &&
            imageBytes != null &&
            tags.isNotEmpty &&
            userName.isNotEmpty
        ? true
        : false;

    var uploadButtonAction = uploadAvailable
        ? () async {
            await sendToAWS();
            if (context.mounted) Navigator.of(context).pop();
          }
        : null;

    return AlertDialog(
      title: const Text('Upload Image'),
      content: form,
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
              foregroundColor: Theme.of(context).colorScheme.error),
          onPressed: uploadingLocally
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          onPressed: uploadButtonAction,
          child: const Text('Upload'),
        ),
      ],
    );
  }
}
