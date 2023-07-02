import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:project_gemastik/Admin/mainPage.dart';

class Books extends StatefulWidget {
  const Books({Key? key}) : super(key: key);

  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Color.fromARGB(210, 241, 205, 205),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
        child: Column(
          children: [
            Row(
              children: [
                WelcomeWidget(),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    Get.to(RichTextHTML());
                  },
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
                stream: FirebaseFirestore.instance
                    .collection('contents')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final List<DocumentSnapshot> documents = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final document = documents[index];
                      final title = document['title'] ?? '';
                      final coverImageUrl = document['coverImageUrl'] ?? '';

                      return GestureDetector(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  side: BorderSide(
                                      width: 1.5, color: Colors.black),
                                ),
                                backgroundColor:
                                    Color.fromARGB(255, 255, 251, 235),
                                title:
                                    Text('Areyou sure want to delete  $title?'),
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
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('contents')
                                            .doc(document.id)
                                            .delete();
                                        FirebaseStorage.instance
                                            .refFromURL(coverImageUrl)
                                            .delete();
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Hapus',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1.5, color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromARGB(255, 194, 225, 251),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    border: Border.all(
                                      width: 1.5,
                                      color: Colors.black,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      coverImageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              //text span
                              Flexible(
                                child: Text(
                                  title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        const Color.fromARGB(255, 20, 20, 20),
                                  ),
                                ),
                              ),

                              SizedBox(width: 10),
                            ],
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

class RichTextHTML extends StatefulWidget {
  const RichTextHTML({Key? key}) : super(key: key);

  @override
  State<RichTextHTML> createState() => _RichTextHTMLState();
}

class _RichTextHTMLState extends State<RichTextHTML> {
  late QuillEditorController controller;
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  String title = '';
  Future<void> _uploadDataToFirebase() async {
    // Perform the necessary steps to upload data and the cover image to Firebase
    // Replace the placeholders with the actual code for uploading the data

    if (_image != null) {
      // Upload the cover image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('cover_images');
      final imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
      final uploadTask =
          storageRef.child('$imageFileName.jpg').putFile(_image!);
      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();

      // Get the HTML content from the editor controller
      final String content = await controller.getText();

      // Save the data, title, and the cover image URL to the Firebase Firestore or Realtime Database
      final databaseRef = FirebaseFirestore.instance.collection('contents');
      await databaseRef.add({
        'title': title,
        'content': content,
        'coverImageUrl': imageUrl,
      });

      // Clear the fields
      setState(() {
        _image = null;
        controller.clear();
        title = '';
      });

      // Show a success message
      Get.snackbar(
        'Success',
        'Data uploaded',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color.fromARGB(240, 126, 186, 148),
        colorText: Colors.black,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(10),
        borderRadius: 10,
        borderColor: Colors.black,
        borderWidth: 1.5,
      );
    } else {
      // Handle the case when no cover image is selected
      Get.snackbar(
        'Error',
        'Please add image cover',
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

  @override
  void initState() {
    controller = QuillEditorController();
    controller.onTextChanged((text) {
      debugPrint('listening to $text');
    });
    super.initState();
  }

  @override
  void dispose() {
    /// please do not forget to dispose the controller
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 255, 247, 229),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 30,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black),
                        borderRadius: BorderRadius.circular(30),
                        color: Color.fromARGB(255, 140, 203, 255),
                      ),
                      child: Icon(MdiIcons.arrowLeft),
                    ),
                  ),
                  Text(
                    'Create new content',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 20, 20, 20),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                  )
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                child: ListView(
                  children: [
                    // Text form field
                    Container(
                      margin: EdgeInsets.only(bottom: 10, left: 4, right: 4),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          labelText: "Content title",
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 20, 20, 20),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the title';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            title = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (_image != null)
                      GestureDetector(
                        onTap: () async {
                          final pickedImage = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (pickedImage != null) {
                            setState(() {
                              _image = File(pickedImage.path);
                            });
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 4, right: 4),
                          height: 300,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            elevation: 0,
                            color: Colors.white,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 300,
                        child: GestureDetector(
                          onTap: () async {
                            final pickedImage = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (pickedImage != null) {
                              setState(() {
                                _image = File(pickedImage.path);
                              });
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 4, right: 4),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(width: 2.0, color: Colors.black),
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 50,
                                  ),
                                  Text(
                                    'Add Cover',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          const Color.fromARGB(255, 20, 20, 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.9,
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        elevation: 0,
                        color: Colors.white,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ToolBar(
                                controller: controller,
                                customButtons: [
                                  //resize image
                                ],
                              ),
                              Divider(
                                thickness: 2,
                                color: Colors.black,
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: QuillHtmlEditor(
                                    controller: controller,
                                    hintText: 'Type something...',
                                    minHeight: 200,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () {
                          _uploadDataToFirebase();
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 4, right: 4),
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                            color: Color.fromARGB(255, 140, 203, 255),
                          ),
                          child: Center(
                            child: Text(
                              "Add content",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromARGB(255, 20, 20, 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
