import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:project_gemastik/classifier/widget/customBottomSheet.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'classifier_category.dart';
import 'classifier_model.dart';

typedef ClassifierLabels = List<String>;

class Classifier {
  final ClassifierLabels _labels;
  final ClassifierModel _model;

  Classifier._({
    required ClassifierLabels labels,
    required ClassifierModel model,
  })  : _labels = labels,
        _model = model;

  static Future<Classifier?> loadWith({
    required String labelsFileName,
    required String modelFileName,
  }) async {
    try {
      final labels = await _loadLabels(labelsFileName);
      final model = await _loadModel(modelFileName);
      return Classifier._(labels: labels, model: model);
    } catch (e) {
      debugPrint('Can\'t initialize Classifier: ${e.toString()}');
      if (e is Error) {
        debugPrintStack(stackTrace: e.stackTrace);
      }
      return null;
    }
  }

  static Future<ClassifierModel> _loadModel(String modelFileName) async {
    final interpreter = await Interpreter.fromAsset(modelFileName);

    // Get input and output shape from the model
    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;

    debugPrint('Input shape: $inputShape');
    debugPrint('Output shape: $outputShape');

    // Get input and output type from the model
    final inputType = interpreter.getInputTensor(0).type;
    final outputType = interpreter.getOutputTensor(0).type;

    debugPrint('Input type: $inputType');
    debugPrint('Output type: $outputType');

    return ClassifierModel(
      interpreter: interpreter,
      inputShape: inputShape,
      outputShape: outputShape,
      inputType: inputType,
      outputType: outputType,
    );
  }

  static Future<ClassifierLabels> _loadLabels(String labelsFileName) async {
    final rawLabels = await FileUtil.loadLabels(labelsFileName);

    // Remove the index number from the label
    final labels = rawLabels
        .map((label) => label.substring(label.indexOf(' ')).trim())
        .toList();

    debugPrint('Labels: $labels');
    return labels;
  }

  void close() {
    _model.interpreter.close();
  }

  ClassifierCategory predict(img.Image image, BuildContext context) {
    debugPrint(
      'Image: ${image.width}x${image.height}, '
      'size: ${image.getBytes().length} bytes',
    );

    // Load the image and convert it to TensorImage for TensorFlow Input
    final inputImage = _preProcessInput(image);

    debugPrint(
      'Pre-processed image: ${inputImage.width}x${image.height}, '
      'size: ${inputImage.buffer.lengthInBytes} bytes',
    );

    // Define the output buffer
    final outputBuffer = TensorBuffer.createFixedSize(
      _model.outputShape,
      _model.outputType,
    );

    // Run inference
    _model.interpreter.run(inputImage.buffer, outputBuffer.buffer);

    debugPrint('OutputBuffer: ${outputBuffer.getDoubleList()}');

    // Post Process the outputBuffer
    final resultCategories = _postProcessOutput(outputBuffer);
    final topResult = resultCategories.first;

    debugPrint('Top category: $topResult');

    // Show modal based on the classification result
    if (topResult.label == 'Glass') {
      _showGlassModal(context);
    } else if (topResult.label == 'Plastic') {
      _showPlasticModal(context);
    } else if (topResult.label == 'Paper') {
      _showPaperModal(context);
    } else if (topResult.label == 'Metal') {
      _showMetalModal(context);
    } else if (topResult.label == 'CardBoard') {
      _showCardBoardModal(context);
    } else if (topResult.label == 'Battery') {
      _showBatteryModal(context);
    } else if (topResult.label == 'Organic') {
      _showOrganicModal(context);
    } else if (topResult.label == 'Electronic') {
      _showElectronicModal(context);
    } else if (topResult.label == 'Medic') {
      _showMedicModal(context);
    }

    return topResult;
  }

  List<ClassifierCategory> _postProcessOutput(TensorBuffer outputBuffer) {
    final probabilityProcessor = TensorProcessorBuilder().build();

    probabilityProcessor.process(outputBuffer);

    final labelledResult = TensorLabel.fromList(_labels, outputBuffer);

    final categoryList = <ClassifierCategory>[];
    labelledResult.getMapWithFloatValue().forEach((key, value) {
      final category = ClassifierCategory(key, value);
      categoryList.add(category);
      debugPrint('label: ${category.label}, score: ${category.score}');
    });
    categoryList.sort((a, b) => (b.score > a.score ? 1 : -1));

    return categoryList;
  }

  TensorImage _preProcessInput(img.Image image) {
    // #1
    final inputTensor = TensorImage(_model.inputType);
    inputTensor.loadImage(image);

    // #2
    final minLength = min(inputTensor.height, inputTensor.width);
    final cropOp = ResizeWithCropOrPadOp(minLength, minLength);

    // #3
    final shapeLength = _model.inputShape[1];
    final resizeOp = ResizeOp(shapeLength, shapeLength, ResizeMethod.BILINEAR);

    // #4
    final normalizeOp = NormalizeOp(127.5, 127.5);

    // #5
    final imageProcessor = ImageProcessorBuilder()
        .add(cropOp)
        .add(resizeOp)
        .add(normalizeOp)
        .build();

    imageProcessor.process(inputTensor);

    // #6
    return inputTensor;
  }

  void _showGlassModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: 'Glass',
          content: Column(
            children: [
              Row(
                children: [Image.network('')],
              )
            ],
          ),
        );
      },
    );
  }

  void _showPlasticModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: 'Plastik',
          content: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 250,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        elevation: 0,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Image.network(
                          'https://firebasestorage.googleapis.com/v0/b/gemastik-407fd.appspot.com/o/material_images%2F2_a26a6b1d-474a-4c65-8c60-327d371274b8_480x480.png?alt=media&token=6c2f5ca0-3717-4ac7-908d-837fe7310040',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                // Informasi tentang sampah plastik
                RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text:
                            'Sampah plastik adalah jenis limbah yang terbuat dari polimer sintetis, yang utamanya berasal dari bahan petrokimia. Plastik membutuhkan waktu yang sangat lama untuk terurai di lingkungan, seringkali ratusan tahun atau lebih, tergantung pada jenis plastiknya. Beberapa barang plastik, seperti botol plastik, bisa membutuhkan waktu hingga 450 tahun untuk terurai.\n\n',
                      ),
                      TextSpan(
                        text:
                            'Sampah plastik telah menjadi masalah lingkungan yang besar karena penggunaannya yang luas dan pembuangannya yang tidak tepat. Diperkirakan bahwa dunia menghasilkan lebih dari 380 juta ton sampah plastik setiap tahunnya. Jumlah sampah plastik yang sangat besar ini memiliki dampak yang serius terhadap lingkungan, antara lain:\n\n',
                      ),
                      TextSpan(
                        text: '- Pencemaran tanah, sungai, dan lautan\n',
                      ),
                      TextSpan(
                        text:
                            '- Bahaya bagi satwa liar, seperti hewan laut yang memakan atau terjerat plastik\n',
                      ),
                      TextSpan(
                        text: '-  Gangguan pada ekosistem\n\n',
                      ),
                      TextSpan(
                        text:
                            'Oleh karena itu penting untuk membuang sampah plastik denga tepat, dan sebisa mungkin untuk mendaur ulang palstik menjadi barang yang bisa dipakai berulang kali\n',
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Get.back();
                    Get.bottomSheet(WasteDisposalForm());
                  },
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        width: 1.5,
                        color: Colors.black,
                      ),
                      color: Color.fromARGB(255, 140, 203, 255),
                    ),
                    child: Center(
                      child: Text(
                        'Buang Sampah',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaperModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: 'Paper',
          content: Column(
            children: [
              Text('Recyclable'),
              // Add more widgets as needed
            ],
          ),
        );
      },
    );
  }

  void _showMetalModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: 'Metal',
          content: Column(
            children: [
              Text('Recyclable'),
              // Add more widgets as needed
            ],
          ),
        );
      },
    );
  }

  void _showCardBoardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: 'CardBoard',
          content: Column(
            children: [
              Text('Recyclable'),
              // Add more widgets as needed
            ],
          ),
        );
      },
    );
  }

  void _showBatteryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: 'Battery',
          content: Column(
            children: [
              Text('Non-Recyclable'),
              // Add more widgets as needed
            ],
          ),
        );
      },
    );
  }

  void _showOrganicModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: 'Food',
          content: Column(
            children: [
              Text('Organic'),
              // Add more widgets as needed
            ],
          ),
        );
      },
    );
  }

  void _showElectronicModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: 'Electronic',
          content: Column(
            children: [
              Text('Non-Recyclable'),
              // Add more widgets as needed
            ],
          ),
        );
      },
    );
  }

  void _showMedicModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: 'Medical',
          content: Column(
            children: [
              Text('Non-Recyclable'),
              // Add more widgets as needed
            ],
          ),
        );
      },
    );
  }
}

class WasteDisposalForm extends StatefulWidget {
  @override
  _WasteDisposalFormState createState() => _WasteDisposalFormState();
}

class _WasteDisposalFormState extends State<WasteDisposalForm> {
  String selectedWasteType = 'Plastik';
  double weight = 0.0;
  String address = '';
  DateTime? selectedDate;
  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    fetchPhoneNumber();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> fetchPhoneNumber() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        String? phoneNumber = data?['phone'];
        setState(() {
          this.phoneNumber = phoneNumber;
        });
      }
    }
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      CollectionReference wasteCollection =
          FirebaseFirestore.instance.collection('dataSampah');
      DocumentReference newDocumentRef = wasteCollection
          .doc(); // Create a new document reference with an auto-generated ID

      newDocumentRef.set({
        'id': newDocumentRef.id, // Save the document ID
        'nama': FirebaseAuth.instance.currentUser?.displayName,
        'nomorTelepon': phoneNumber,
        'jenisSampah': selectedWasteType,
        'berat': weight,
        'alamat': address,
        'tanggal': selectedDate,
        'status': 'Menunggu',
      }).then((value) {
        // Document successfully added
        Get.snackbar(
          'Terimakasih',
          'Kami akan segera menghubungi kamu',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color.fromARGB(240, 126, 186, 148),
          colorText: Colors.black,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(10),
          borderRadius: 10,
          borderColor: Colors.black,
          borderWidth: 1.5,
        );
      }).catchError((error) {
        // Error occurred while saving document
        Get.snackbar(
          'Error',
          error.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color.fromARGB(244, 249, 135, 127),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(10),
          borderRadius: 10,
          borderColor: Colors.black,
          borderWidth: 1.5,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 248, 235),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        border: Border.all(width: 1.5, color: Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                height: 5,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nama : ',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    FirebaseAuth.instance.currentUser?.displayName ?? "",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nomor telepon : ',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    phoneNumber ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jenis Sampah : ',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedWasteType,
                    onChanged: (newValue) {
                      setState(() {
                        selectedWasteType = newValue!;
                      });
                    },
                    items: <String>[
                      'Plastik',
                      'Logam',
                      'Kaca',
                      'Kertas',
                      'Karton'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Kisaran berat (kg)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Berat harus diisi';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    weight = double.parse(value);
                  });
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Alamat penjemputan',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat harus diisi';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    address = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  ).then((DateTime? date) {
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  });
                },
                child: Text(
                  selectedDate != null
                      ? DateFormat('dd-MM-yyyy').format(selectedDate!)
                      : 'Pilih Tanggal',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  submitForm();
                  //update point
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .update({
                    'Point': FieldValue.increment(weight * 3000),
                  });
                  Get.back();
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      width: 1.5,
                      color: Colors.black,
                    ),
                    color: Color.fromARGB(255, 140, 203, 255),
                  ),
                  child: Center(
                    child: Text(
                      'Submit',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
