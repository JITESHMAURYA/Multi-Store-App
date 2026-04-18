import 'package:flutter/material.dart';
import 'package:app_web/controllers/order_controller.dart';
import 'package:app_web/models/order.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({super.key});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  late Future<List<Order>> futureOrders;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureOrders = OrderController().fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    Widget orderData(int flex, Widget widget) {
      return Expanded(
        flex: flex,
        child: Container(
          decoration: BoxDecoration(),
          child: Padding(padding: const EdgeInsets.all(8.0), child: widget),
        ),
      );
    }

    return FutureBuilder(
      future: futureOrders,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('error:${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No Orders'));
        } else {
          final orders = snapshot.data!;

          return SizedBox(
            height: 400,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Column(
                  children: [
                    Row(
                      children: [
                        orderData(
                          2,
                          Image.network(order.image, width: 50, height: 50),
                        ),
                        orderData(
                          3,
                          Text(
                            order.productName,
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        orderData(
                          2,
                          Text(
                            '\₹${order.productPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                        orderData(
                          2,
                          Text(
                            order.category,
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        orderData(
                          2,
                          Text(
                            order.fullName,
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        orderData(
                          3,
                          Text(
                            order.email,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        orderData(
                          3,
                          Text(
                            '${order.city}, ${order.state}',
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        orderData(
                          2,
                          Text(
                            order.delivered == true
                                ? 'delivered'
                                : order.processing == true
                                ? 'processing'
                                : 'canceled',
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          );
        }
      },
    );
  }
}
