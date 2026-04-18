import 'dart:convert';

import 'package:multi_store_app/global_variables.dart';
import 'package:multi_store_app/models/product.dart';
import 'package:http/http.dart' as http;

class ProductController {
  //Define a function that returns a future containing list of the product model objects
  Future<List<Product>> loadPopularProducts() async {
    //use a try block to handle any exceptions that might occured in the http request
    try {
      http.Response response = await http.get(
        Uri.parse("$uri/api/popular-products"),
        //set the http headers for the request, specifying that the content type is json with the UTF-8 encoding
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      //check if the HTTP response status code is 200, which means the request was succesfull
      if (response.statusCode == 200) {
        //Decode the json response body into a list of dynamic object
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        //map each items in the list to product model object which we can use
        List<Product> products = data
            .map((product) => Product.fromMap(product as Map<String, dynamic>))
            .toList();
        return products;
      } else {
        //if status code is not 200, throw an exception indicating faliur to load the popular products
        throw Exception('Failed to load popular products');
      }
    } catch (e) {
      throw Exception('Error loading product : $e');
    }
  }

  //load product by category function
  Future<List<Product>> loadProductByCategory(String category) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/products-by-category/$category'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        //Decode the json response body into a list of dynamic object
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        //map each items in the list to product model object which we can use
        List<Product> products = data
            .map((product) => Product.fromMap(product as Map<String, dynamic>))
            .toList();
        return products;
      } else {
        //if status code is not 200, throw an exception indicating faliur to load the popular products
        throw Exception('Failed to load popular products');
      }
    } catch (e) {
      throw Exception('Error loading product : $e');
    }
  }

  //display related product by subcategory
  Future<List<Product>> loadRelatedProductsBySubcategory(
    String productId,
  ) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/related-products-by-subcategory/$productId'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        //Decode the json response body into a list of dynamic object
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        //map each items in the list to product model object which we can use
        List<Product> relatedProducts = data
            .map((product) => Product.fromMap(product as Map<String, dynamic>))
            .toList();
        return relatedProducts;
      } else {
        //if status code is not 200, throw an exception indicating faliur to load the popular products
        throw Exception('Failed to load related products');
      }
    } catch (e) {
      throw Exception('Error loading related products : $e');
    }
  }
}
