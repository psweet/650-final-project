import 'dart:ui';

import 'package:final_project/image_class.dart';
import 'package:final_project/image_grid.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:final_project/upload_dialog.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:final_project/models/ModelProvider.dart' as modelprovider;

import 'package:amplify_api/amplify_api.dart';
import 'amplifyconfiguration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await _configureAmplify();
  } on AmplifyAlreadyConfiguredException {
    debugPrint('Amplify configuration failed.');
  }

  runApp(const MainApp());
}

Future<void> _configureAmplify() async {
  final auth = AmplifyAuthCognito();
  final storage = AmplifyStorageS3();
  await Amplify.addPlugins([
    AmplifyAPI(modelProvider: modelprovider.ModelProvider.instance),
    auth,
    storage
  ]);
  await Amplify.configure(amplifyconfig);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DATA650 Final Project',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  String searchText = "";

  List<CustomImage> images = [];

  Future<void> _getImages() async {
    try {
      final request = ModelQueries.list(modelprovider.Image.classType);
      final response = await Amplify.API.query(request: request).response;

      final awsImages = response.data?.items;
      if (response.hasErrors) {
        safePrint('errors: ${response.errors}');
        return;
      }
      images = [];
      for (modelprovider.Image img
          in awsImages!.whereType<modelprovider.Image>().toList()) {
        images.add(await CustomImage.fromImage(img));
      }
    } on ApiException catch (e) {
      safePrint('Query failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _getImages(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ImageGrid(
              searchText,
              () {
                setState(() {});
              },
              images: [
                ...images.where((element) =>
                    element.tags.any((tag) =>
                        tag.toLowerCase().contains(searchText.toLowerCase())) ||
                    searchText == "")
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SearchBar(
        onSubmitted: (value) {
          setState(() {
            searchText = value;
          });
        },
        padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0)),
        leading: const Icon(Icons.search),
        elevation: const MaterialStatePropertyAll(3),
        hintText: "Search tags",
        trailing: [
          IconButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return UploadDialog(
                    runCode: () {
                      setState(() {});
                    },
                    existingTags: images.expand((e) => e.tags).toSet(),
                  );
                },
              );
            },
            icon: const Icon(Icons.upload_file),
          )
        ],
      ),
    );
  }
}
