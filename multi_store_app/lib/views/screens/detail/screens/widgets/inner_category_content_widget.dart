import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_store_app/controllers/product_controller.dart';
import 'package:multi_store_app/controllers/subcategory_controller.dart';
import 'package:multi_store_app/models/category.dart';
import 'package:multi_store_app/models/product.dart';
import 'package:multi_store_app/models/subcategory.dart';
import 'package:multi_store_app/views/screens/detail/screens/widgets/inner_banner_widget.dart';
import 'package:multi_store_app/views/screens/detail/screens/widgets/inner_header_widget.dart';
import 'package:multi_store_app/views/screens/detail/screens/widgets/subcategory_tile_widget.dart';
import 'package:multi_store_app/views/screens/nav_screens/widgets/product_item_widget.dart';
import 'package:multi_store_app/views/screens/nav_screens/widgets/reusable_text_widget.dart';

class InnerCategoryContentWidget extends StatefulWidget {
  final Category category;

  const InnerCategoryContentWidget({super.key, required this.category});

  @override
  State<InnerCategoryContentWidget> createState() =>
      _InnerCategoryScreenState();
}

class _InnerCategoryScreenState extends State<InnerCategoryContentWidget> {
  late Future<List<Subcategory>> _subcategories;
  late Future<List<Product>> futureProducts;
  final SubcategoryController _subcategoryController = SubcategoryController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _subcategories = _subcategoryController.getSubCategoriesByCategoryName(
      widget.category.name,
    );
    futureProducts = ProductController().loadProductByCategory(
      widget.category.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 20),
        child: InnerHeaderWidget(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InnerBannerWidget(image: widget.category.banner),
            Center(
              child: Text(
                "Shop by Category",
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FutureBuilder(
              future: _subcategories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No Categories'));
                } else {
                  final subcategories = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: List.generate((subcategories.length / 7).ceil(), (
                        setIndex,
                      ) {
                        //for each row, calculate the starting and ending indices
                        final start = setIndex * 7;
                        final end = (setIndex + 1) * 7;
                        //create a padding widget to add spacing around the row
                        return Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            //create a row of the subcategory tile
                            children: subcategories
                                .sublist(
                                  start,
                                  end > subcategories.length
                                      ? subcategories.length
                                      : end,
                                )
                                .map(
                                  (subcategory) => SubcategoryTileWidget(
                                    image: subcategory.image,
                                    title: subcategory.subCategoryName,
                                  ),
                                )
                                .toList(),
                          ),
                        );
                      }),
                    ),
                  );
                }
              },
            ),
            ReusableTextWidget(title: 'Popular Product', subtitle: 'View all'),
            FutureBuilder(
              future: futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No product under this category'));
                } else {
                  final products = snapshot.data;
                  return SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: products!.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductItemWidget(product: product);
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
