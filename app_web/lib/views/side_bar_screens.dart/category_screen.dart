import 'package:app_web/controllers/category_controller.dart';
import 'package:app_web/views/side_bar_screens.dart/widgets/category_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  static const String id = '\category-screen';
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CategoryController _categoryController = CategoryController();
  late String name;
  dynamic _image;
  dynamic _bannerImage;

  pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        _image = result.files.first.bytes;
      });
    }
  }

  pickBannerImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        _bannerImage = result.files.first.bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  'Categories',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: Divider(color: Colors.grey),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: _image != null
                          ? Image.memory(_image)
                          : const Text('Category Image'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 200,
                    child: TextFormField(
                      onChanged: (value) {
                        name = value;
                      },
                      validator: (value) {
                        if (value!.isNotEmpty) {
                          return null;
                        } else {
                          return 'please enter category name';
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Enter Category Name',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _categoryController.uploadCategory(
                        name: name,
                        pickedImage: _image,
                        pickedBanner: _bannerImage,
                        context: context,
                      );
                      setState(() {
                        _formKey.currentState!.reset();
                        _image = null;
                        _bannerImage = null;
                        name = "";
                      });
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                left: 22,
                bottom: 8,
                right: 18,
              ),
              child: ElevatedButton(
                onPressed: () {
                  pickImage();
                },
                child: const Text('Pick Image'),
              ),
            ),
            const Divider(color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _bannerImage != null
                      ? Image.memory(_bannerImage)
                      : const Text(
                          'Category Banner',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                left: 22,
                bottom: 8,
                right: 18,
              ),
              child: ElevatedButton(
                onPressed: () {
                  pickBannerImage();
                },
                child: const Text('Pick Image'),
              ),
            ),
            const Divider(color: Colors.grey),
            const CategoryWidget(),
          ],
        ),
      ),
    );
  }
}
