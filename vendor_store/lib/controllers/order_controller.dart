import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vendor_store/global_variables.dart';
import 'package:vendor_store/models/order.dart';
import 'package:vendor_store/services/manage_http_response.dart';

class OrderController {
  // Method to GET orders by vendor id
  Future<List<Order>> loadOrders({required String vendorId}) async {
    try {
      //send an http get requrest to get the orders by the vendorId
      http.Response response = await http.get(
        Uri.parse('$uri/api/orders/vendors/$vendorId'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      //check if the response status code is 200(OK)
      if (response.statusCode == 200) {
        //parse the json responsse body into dynamic list
        //this convert the json data into a format that can be further processed in dart
        List<dynamic> data = jsonDecode(response.body);
        //Map the dynamic list to list of orders object using the fromjson factory method
        //this step converts the raw data into list of the orders instances, which are easier to work with
        List<Order> orders = data
            .map((order) => Order.fromJson(order))
            .toList();
        return orders;
      }
      {
        //throw an exception if the server responded with an error status code
        throw Exception("failed to load Orders");
      }
    } catch (e) {
      throw Exception('Error Loading Orders');
    }
  }

  //delete order by ID
  Future<void> deleteOrder({required String id, required context}) async {
    try {
      //send an http delete request to delete the order by _id
      http.Response response = await http.delete(
        Uri.parse("$uri/api/orders/$id"),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      //handle the HTTP response
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Order Deleted Successfully");
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> updateDeliveryStatus({
    required String id,
    required context,
  }) async {
    try {
      http.Response response = await http.patch(
        Uri.parse('$uri/api/orders/$id/delivered'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"delivered": true, "processing": false}),
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Order Updated");
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> cancelOrder({required String id, required context}) async {
    try {
      http.Response response = await http.patch(
        Uri.parse('$uri/api/orders/$id/processing'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"processing": false, "delivered": false}),
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Order Canceled");
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
