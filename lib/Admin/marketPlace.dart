import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_gemastik/Admin/mainPage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarketPlace extends StatefulWidget {
  const MarketPlace({Key? key}) : super(key: key);

  @override
  State<MarketPlace> createState() => _MarketPlaceState();
}

class _MarketPlaceState extends State<MarketPlace> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _ProductNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _selectedCategory = '';
  List<String> _documentIds = [];
  List<File> _selectedImages = [];
  final CarouselController _carouselController = CarouselController();
  int _selectedIndex = 0;

  // Define the shared text style and input decoration
  final TextStyle _textStyle = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color.fromARGB(255, 20, 20, 20),
  );

  final InputDecoration _inputDecoration = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    labelStyle: TextStyle(
      color: Color.fromARGB(255, 20, 20, 20),
    ),
  );

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('products').get();
      setState(() {
        _products = snapshot.docs
            .map<Map<String, dynamic>>(
                (doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _isLoading = false;
      });
    } catch (error) {
      // Show an error message or handle the error
      print('Error fetching products: $error');
    }
  }

  void _addNewProduct() async {
    // Get the values from the text controllers
    final String title = _ProductNameController.text;
    final String description = _descriptionController.text;
    final double price = double.tryParse(_priceController.text) ?? 0.0;

    // Validate the input fields
    if (title.isEmpty ||
        description.isEmpty ||
        price <= 0.0 ||
        _selectedImages.isEmpty) {
      // Show an error message or handle the validation error
      return;
    }

    try {
      // Upload images to Firebase Storage
      List<String> imageUrls = [];
      for (final imageFile in _selectedImages) {
        final String fileName =
            DateTime.now().millisecondsSinceEpoch.toString();
        final Reference storageRef =
            _storage.ref().child('product_images/$fileName');
        final UploadTask uploadTask = storageRef.putFile(imageFile);
        final TaskSnapshot uploadSnapshot =
            await uploadTask.whenComplete(() {});
        final String imageUrl = await uploadSnapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      // Save the product data to Firestore
      final DocumentReference productRef =
          await _firestore.collection('products').add({
        'title': title,
        'description': description,
        'price': price,
        'category': _selectedCategory,
        'images': imageUrls,
      });

      // Show a success message or navigate to a different screen
      // Clear the values and close the bottom sheet
      _ProductNameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _selectedImages.clear();
      _selectedIndex = 0;
      Navigator.pop(context);
      Get.snackbar(
        'Success',
        'Success to add new product',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color.fromARGB(240, 126, 186, 148),
        colorText: Colors.black,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(10),
        borderRadius: 10,
        borderColor: Colors.black,
        borderWidth: 1.5,
      );
    } catch (error) {
      // Show an error message or handle the error
      Get.snackbar(
        'Error',
        'New product failed to add',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color.fromARGB(244, 249, 135, 127),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(10),
        borderRadius: 10,
        borderColor: Colors.black,
        borderWidth: 1.5,
      );
    }
  }

  void _showAddItemBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: FractionallySizedBox(
          heightFactor: 0.8,
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 248, 235),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              border: Border.all(width: 1.5, color: Colors.black),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(15),
                    height: 5,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Text(
                              "Add new product",
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 20, 20, 20),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            decoration: _inputDecoration.copyWith(
                              labelText: 'Product Name',
                            ),
                            style: _textStyle,
                            onChanged: (value) {
                              setState(() {
                                _ProductNameController.text = value;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            decoration: _inputDecoration.copyWith(
                              labelText: 'Description',
                            ),
                            style: _textStyle,
                            onChanged: (value) {
                              setState(() {
                                _descriptionController.text = value;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            decoration: _inputDecoration.copyWith(
                              labelText: 'Price',
                            ),
                            style: _textStyle,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _priceController.text = value;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            items: [
                              DropdownMenuItem(
                                child: Text('Plastic'),
                                value: 'Plastic',
                              ),
                              DropdownMenuItem(
                                child: Text('Paper'),
                                value: 'Paper',
                              ),
                              DropdownMenuItem(
                                child: Text('Metal'),
                                value: 'Metal',
                              ),
                            ],
                            decoration: _inputDecoration.copyWith(
                              labelText: 'Category',
                            ),
                            style: _textStyle,
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // there is no image
                          if (_selectedImages.isEmpty)
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                                border:
                                    Border.all(width: 1.5, color: Colors.black),
                              ),
                              child: Icon(
                                Icons.photo,
                                size: 80,
                              ),
                            ) // else there is an image
                          else
                            CarouselSlider(
                              options: CarouselOptions(
                                height: 200,
                                enableInfiniteScroll: false,
                                viewportFraction: 1.0,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _selectedIndex =
                                        index; // Update the selected index
                                  });
                                },
                              ),
                              items: _selectedImages.map((image) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      width: MediaQuery.of(context).size.width,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            width: 1.5, color: Colors.black),
                                      ),
                                      child: Image.file(
                                        image,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: _selectImages,
                            child: Container(
                              margin: EdgeInsets.only(top: 10),
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Color.fromARGB(255, 255, 219, 153),
                                border:
                                    Border.all(width: 1.5, color: Colors.black),
                              ),
                              child: Center(
                                child: Text(
                                  'Select Image Product',
                                  style: GoogleFonts.rubik(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Handle adding new product
                              _addNewProduct();
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 10),
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Color.fromARGB(176, 126, 186, 148),
                                border:
                                    Border.all(width: 1.5, color: Colors.black),
                              ),
                              child: Center(
                                child: Text(
                                  'Add New Product',
                                  style: GoogleFonts.rubik(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectImages() async {
    final picker = ImagePicker();
    List<File> selectedImages = [];

    final pickedImages =
        await picker.pickMultiImage(imageQuality: 80, maxWidth: 800);

    if (pickedImages != null) {
      for (final pickedImage in pickedImages) {
        selectedImages.add(File(pickedImage.path));
      }
    }

    setState(() {
      _selectedImages = selectedImages;
      //refresh
    });
  }

  void _showDeleteConfirmationDialog(
      DocumentReference documentReference, List<dynamic> imageUrls) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete this product?'),
          actions: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(193, 225, 156, 156),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(150, 126, 186, 148),
              ),
              child: TextButton(
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () {
                  _deleteProduct(documentReference, imageUrls);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteFile(String imageUrl) async {
    try {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
    } catch (e) {
      print("Error deleting image from storage: $e");
    }
  }

  Future<void> _deleteProduct(
      DocumentReference documentReference, List<dynamic> imageUrls) async {
    // Delete from Firestore
    await documentReference.delete();

    // Delete images from Firebase Storage
    for (String imageUrl in imageUrls) {
      await deleteFile(imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Color.fromARGB(193, 255, 248, 235),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
        child: Column(
          children: [
            Row(
              children: [
                WelcomeWidget(),
                SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: _showAddItemBottomSheet, // Show the bottom sheet
                  child: itemAppBar(
                    iconbarColor: Color.fromARGB(160, 126, 186, 148),
                    iconbar: Icon(
                      Icons.add_circle_outline,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('products').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  if (documents.isEmpty) {
                    return Center(
                      child: Text(
                        'No products found',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color.fromARGB(255, 20, 20, 20),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot document = documents[index];
                      final String title = document['title'] ?? '';
                      final String description = document['description'] ?? '';
                      final double price = document['price'] ?? 0.0;
                      final List<dynamic> imageUrls = document['images'] ?? [];

                      return GestureDetector(
                        onLongPress: () => _showDeleteConfirmationDialog(
                            document.reference, imageUrls),
                        child: Dismissible(
                          key: Key(document.id),
                          onDismissed: (_) =>
                              _deleteProduct(document.reference, imageUrls),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            color: Colors.red,
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.5, color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromARGB(255, 194, 225, 251),
                            ),
                            child: ListTile(
                              title: Text(
                                title,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: const Color.fromARGB(255, 20, 20, 20),
                                ),
                              ),
                              subtitle: Text(
                                description,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: const Color.fromARGB(255, 20, 20, 20),
                                ),
                              ),
                              trailing: Text(
                                '\Rp ${price.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color.fromARGB(255, 20, 20, 20),
                                ),
                              ),
                              leading: imageUrls.isNotEmpty
                                  ? Container(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1.5, color: Colors.black),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Image.network(
                                        imageUrls[0],
                                        fit: BoxFit.cover,
                                        width: 70,
                                        height: 70,
                                      ),
                                    )
                                  : Icon(Icons.image),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
