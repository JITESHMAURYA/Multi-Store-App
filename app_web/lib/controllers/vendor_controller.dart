import 'dart:convert';
import 'package:app_web/global_variables.dart';
import 'package:http/http.dart' as http;
import 'package:app_web/models/vendor.dart';

class VendorController {
  // load buyers
  Future<List<Vendor>> fetchVendors() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/vendors'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Vendor> vendors = data
            .map((vendor) => Vendor.fromMap(vendor))
            .toList();
        return vendors;
      } else {
        throw Exception('Failed to load Vendors');
      }
    } catch (e) {
      throw Exception('Error loading Vendors:$e');
    }
  }
}
