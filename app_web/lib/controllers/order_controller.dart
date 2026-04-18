import 'dart:convert';
import 'package:app_web/global_variables.dart';
import 'package:http/http.dart' as http;
import 'package:app_web/models/order.dart';

class OrderController {
  // load orders
  Future<List<Order>> fetchOrders() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/orders'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Order> orders = data
            .map((order) => Order.fromJson(order))
            .toList();
        return orders;
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('Error loading orders:$e');
    }
  }
}
