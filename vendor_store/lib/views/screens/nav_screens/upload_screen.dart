// Old
// import 'dart:io';
// New
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_store/controllers/category_controller.dart';
import 'package:vendor_store/controllers/product_controller.dart';
import 'package:vendor_store/controllers/subcategory_controller.dart';
import 'package:vendor_store/models/category.dart';
import 'package:vendor_store/models/subcategory.dart';
import 'package:vendor_store/provider/vendor_provider.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProductController _productController = ProductController();
  late Future<List<Category>> futureCategories;
  Future<List<Subcategory>>? futureSubcategories;
  Category? selectedCategory;
  Subcategory? seletedSubcategory;
  late String productName;
  late int productPrice;
  late int quantity;
  late String description;

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureCategories = CategoryController().loadCategories();
  }

  //Create an instance of imagePicker to handle image selection
  final ImagePicker picker = ImagePicker();

  //initialize an empty list to store the selected images
  // Old
  // List<File> images = [];
  // New
  List<Uint8List> images = [];

  //Define a function to choose image from the galary
  chooseImage() async {
    //Use the picker to select an image from the galary
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    //check if no image was picked
    if (pickedFile == null) {
      print('No image Picked');
    } else {
      //if an image was picked, update the state(UI) and add the image to the list
      // Old
      // setState(() {
      //   images.add(File(pickedFile.path));
      // });
      //New
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        images.add(bytes);
      });
    }
  }

  getSubcategoryByCategory(value) {
    //fetch subcategories based on the selected category
    futureSubcategories = SubcategoryController()
        .getSubCategoriesByCategoryName(value.name);
    //reset the selected Subcategory
    seletedSubcategory = null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.builder(
              shrinkWrap: true, //allow the gridView to shink to fit the content
              itemCount:
                  images.length +
                  1, //the no of items in the grid (+1 for the add button)
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                //if the index is 0, display an icon button to add a new image
                return index == 0
                    ? Center(
                        child: IconButton(
                          onPressed: () {
                            chooseImage();
                          },
                          icon: Icon(Icons.add),
                        ),
                      )
                    : SizedBox(
                        width: 50,
                        height: 40,
                        // Old
                        // child: Image.file(images[index - 1]),
                        // New
                        child: Image.memory(images[index - 1]),
                      );
              },
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      onChanged: (value) {
                        productName = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Product Name";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter Product Name',
                        hintText: 'Enter Product Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        productPrice = int.parse(value);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Product Price";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter Product Price',
                        hintText: 'Enter Product Price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        quantity = int.parse(value);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Product Quantity";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter Product Quantity',
                        hintText: 'Enter Product Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    child: FutureBuilder<List<Category>>(
                      future: futureCategories,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('No Category'));
                        } else {
                          return DropdownButton<Category>(
                            value: selectedCategory,
                            hint: Text('Select Category'),
                            items: snapshot.data!.map((Category category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                              });
                              getSubcategoryByCategory(selectedCategory);
                            },
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: FutureBuilder<List<Subcategory>>(
                      future: futureSubcategories,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('No Subcategory'));
                        } else {
                          return DropdownButton<Subcategory>(
                            value: seletedSubcategory,
                            hint: Text('Select Subcategory'),
                            items: snapshot.data!.map((
                              Subcategory subcategory,
                            ) {
                              return DropdownMenuItem(
                                value: subcategory,
                                child: Text(subcategory.subCategoryName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                seletedSubcategory = value;
                              });
                            },
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      onChanged: (value) {
                        description = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Product Description";
                        } else {
                          return null;
                        }
                      },
                      maxLines: 3,
                      maxLength: 500,
                      decoration: InputDecoration(
                        labelText: 'Enter Product Description',
                        hintText: 'Enter Product Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: InkWell(
                onTap: () async {
                  final fullName = ref.read(vendorProvider)!.fullName;
                  final vendorId = ref.read(vendorProvider)!.id;
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    await _productController
                        .uploadProduct(
                          productName: productName,
                          productPrice: productPrice,
                          quantity: quantity,
                          description: description,
                          category: selectedCategory!.name,
                          vendorId: vendorId,
                          fullName: fullName,
                          subCategory: seletedSubcategory!.subCategoryName,
                          pickImages: images,
                          context: context,
                        )
                        .whenComplete(() {
                          setState(() {
                            isLoading = false;
                          });
                          selectedCategory = null;
                          seletedSubcategory = null;
                          images.clear();
                        });
                  } else {
                    print('Please enter all the fields');
                  }
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Upload Product',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.7,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
