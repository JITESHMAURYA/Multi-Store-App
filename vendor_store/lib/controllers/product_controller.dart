// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:cloudinary_public/cloudinary_public.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vendor_store/global_variables.dart';
// import 'package:vendor_store/models/product.dart';
// import 'package:vendor_store/services/manage_http_response.dart';

// class ProductController {
//   Future<void> uploadProduct({
//     required String productName,
//     required int productPrice,
//     required int quantity,
//     required String description,
//     required String category,
//     required String vendorId,
//     required String fullName,
//     required String subCategory,
//     required List<File>? pickImages,
//     required context,
//   }) async {
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     String? token = sharedPreferences.getString('auth_token');
//     if (pickImages != null) {
//       final cloudinary = CloudinaryPublic('dwobjlgow', 'ha9xksq3');
//       List<String> images = [];
//       //loop through each image in the pickedImages List
//       for (var i = 0; i < pickImages.length; i++) {
//         //await the upload of the current image to cloudinary
//         CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
//           CloudinaryFile.fromFile(pickImages[i].path, folder: productName),
//         );
//         //add the secure Url to the images list
//         images.add(cloudinaryResponse.secureUrl);
//       }
//       if (category.isNotEmpty && subCategory.isNotEmpty) {
//         final Product product = Product(
//           id: '',
//           productName: productName,
//           productPrice: productPrice,
//           quantity: quantity,
//           description: description,
//           category: category,
//           vendorId: vendorId,
//           fullName: fullName,
//           subCategory: subCategory,
//           images: images,
//         );
//         http.Response response = await http.post(
//           Uri.parse("$uri/api/add-product"),
//           body: product.toJson(),
//           headers: <String, String>{
//             "Content-Type": 'application/json; charset=UTF-8',
//             'x-auth-token': token!,
//           },
//         );
//         manageHttpResponse(
//           response: response,
//           context: context,
//           onSuccess: () {
//             showSnackBar(context, 'Product Uploaded');
//           },
//         );
//       } else {
//         showSnackBar(context, 'Select Category');
//       }
//     } else {
//       showSnackBar(context, 'Select Image');
//     }
//   }
// }

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:vendor_store/global_variables.dart';
import 'package:vendor_store/models/product.dart';
import 'package:vendor_store/services/manage_http_response.dart';

class ProductController {
  Future<void> uploadProduct({
    required String productName,
    required int productPrice,
    required int quantity,
    required String description,
    required String category,
    required String vendorId,
    required String fullName,
    required String subCategory,
    required List<Uint8List>? pickImages,
    required context,
  }) async {
    if (pickImages != null && pickImages.isNotEmpty) {
      final cloudinary = CloudinaryPublic('dwobjlgow', 'ha9xksq3');

      List<String> images = [];

      // Upload each image using bytes (WEB SAFE)
      for (int i = 0; i < pickImages.length; i++) {
        CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(
            pickImages[i],
            identifier: 'product_$i',
            folder: productName,
          ),
        );

        images.add(cloudinaryResponse.secureUrl);
      }

      if (category.isNotEmpty && subCategory.isNotEmpty) {
        final Product product = Product(
          id: '',
          productName: productName,
          productPrice: productPrice,
          quantity: quantity,
          description: description,
          category: category,
          vendorId: vendorId,
          fullName: fullName,
          subCategory: subCategory,
          images: images,
        );

        http.Response response = await http.post(
          Uri.parse("$uri/api/add-product"),
          body: product.toJson(),
          headers: <String, String>{
            "Content-Type": 'application/json; charset=UTF-8',
          },
        );

        manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, 'Product Uploaded');
          },
        );
      } else {
        showSnackBar(context, 'Select Category');
      }
    } else {
      showSnackBar(context, 'Select Image');
    }
  }
}
