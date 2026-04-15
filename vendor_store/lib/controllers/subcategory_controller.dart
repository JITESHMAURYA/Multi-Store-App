import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vendor_store/global_variables.dart';
import 'package:vendor_store/models/subcategory.dart';

class SubcategoryController {
  Future<List<Subcategory>> getSubCategoriesByCategoryName(
    String categoryName,
  ) async {
    try {
      http.Response response = await http.get(
        Uri.parse("$uri/api/category/$categoryName/subcategories"),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data
              .map((subcategory) => Subcategory.fromJson(subcategory))
              .toList();
        } else {
          print("Subcategories not found");
          return [];
        }
      } else if (response.statusCode == 404) {
        print("Subcategories not found");
        return [];
      } else {
        print("Failed to fetch subcategories");
        return [];
      }
    } catch (e) {
      print("Error fetching categories : $e");
      return [];
    }
  }
}
