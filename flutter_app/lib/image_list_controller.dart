// import 'dart:async';

// import 'package:amplify_flutter/amplify_flutter.dart';
// import 'package:final_project/images_repo.dart';
// import 'package:final_project/models/Image.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'images_list_controller.g.dart';

// @riverpod
// class ImagesListController extends _$ImagesListController {
//   Future<List<Image>> _fetchImages() async {
//     final imagesRepository = ref.read(imagesRepositoryProvider);
//     final images = await imagesRepository.getImages();
//     return images;
//   }

//   @override
//   FutureOr<List<Image>> build() async {
//     return _fetchImages();
//   }

//   Future<void> addImage({
//     required String name,
//     required String resolution,
//     required String owner,
//     required String uploadDate,
//     required String colorspace,
//   }) async {
//     final image = Image(
//       id: name,
//       resolution: resolution,
//       owner: owner,
//       uploadDate: TemporalDate(
//         DateTime.parse(uploadDate),
//       ),
//       colorspace: colorspace,
//     );

//     AsyncValue<dynamic> state = const AsyncValue.loading();

//     state = await AsyncValue.guard(() async {
//       final imagesRepository = ref.read(imagesRepositoryProvider);
//       await imagesRepository.add(image);
//       return _fetchImages();
//     });
//   }

//   Future<void> removeImage(Image image) async {
//     AsyncValue<dynamic> state = const AsyncValue.loading();
//     state = await AsyncValue.guard(() async {
//       final imagesRepository = ref.read(imagesRepositoryProvider);
//       await imagesRepository.delete(image);

//       return _fetchImages();
//     });
//   }
// }
