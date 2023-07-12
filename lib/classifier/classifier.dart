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
          title: 'Sampah Kaca',
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
                          'https://firebasestorage.googleapis.com/v0/b/gemastik-407fd.appspot.com/o/material_images%2Fglass-recycling.jpg?alt=media&token=7ec0b709-45b7-428b-b506-5fd72d58dc52',
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
                            'Kaca adalah bahan yang dapat didaur ulang dan memiliki umur terurai yang sangat lama. Kaca dapat terurai dalam waktu yang sangat panjang, bahkan berabad-abad. Namun, kaca yang terbuang di lingkungan dapat membutuhkan waktu yang lebih lama untuk terurai karena kondisi lingkungan yang tidak ideal.\n\n',
                      ),
                      TextSpan(
                        text:
                            'Jumlah sampah kaca yang dihasilkan di seluruh dunia cukup signifikan. Tidak ada angka pasti yang menunjukkan jumlah sampah kaca secara global, tetapi produksi dan konsumsi kaca yang tinggi menyebabkan peningkatan sampah kaca. Kaca yang paling umum adalah kaca pembungkus makanan, botol, kaca jendela, dan kaca dekoratif.\n\n',
                      ),
                      TextSpan(
                        text:
                            'Sampah kaca dapat memiliki dampak positif terhadap lingkungan jika didaur ulang dengan benar. Namun, jika kaca terbuang di lingkungan, dapat menyebabkan dampak negatif. Beberapa dampak negatif dari sampah kaca termasuk penumpukan di tempat pembuangan akhir, penggunaan sumber daya alam yang berlebihan, dan konsumsi energi yang tinggi selama proses produksi kaca baru.\n\n',
                      ),
                      TextSpan(
                        text: 'Cara mendaur ulang sampah :\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            '1. Pisahkan kaca dari sampah lainnya. Tempatkan kaca dalam wadah yang khusus untuk daur ulang atau kumpulkan dalam kontainer kaca terpisah.\n\n',
                      ),
                      TextSpan(
                        text:
                            '2. Pastikan kaca yang dikumpulkan bersih dari kontaminasi. Sortir kaca berdasarkan jenis dan warna. Beberapa jenis kaca, seperti kaca jendela, mungkin mengandung lapisan atau bahan tambahan yang perlu dihapus sebelum didaur ulang.\n\n',
                      ),
                      TextSpan(
                        text:
                            '3.  Bawa kaca yang sudah terpisah dan bersih ke fasilitas daur ulang.\n\n',
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

  void _showPlasticModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: 'Sampah Plastik',
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
                        text: '1. Pencemaran tanah, sungai, dan lautan\n',
                      ),
                      TextSpan(
                        text:
                            '2. Bahaya bagi satwa liar, seperti hewan laut yang memakan atau terjerat plastik\n',
                      ),
                      TextSpan(
                        text: '3. Gangguan pada ekosistem\n\n',
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
          title: 'Sampah Kertas',
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
                          'https://firebasestorage.googleapis.com/v0/b/gemastik-407fd.appspot.com/o/material_images%2Fsampah-kertas-limbah-kertas-hemat-kertas-mencegah-kerusakan-ekosistem-alam-bahan-baku-pembuatan-kertas-cara-buat-kertas.jpg?alt=media&token=fc28f478-3d59-46d7-8926-e4b37b643a29',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                // Informasi tentang sampah kertas
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
                            'Sebagai salah satu sektor industri terbesar di dunia, industri pulp dan kertas menimbulkan ancaman deforestasi bagi hutan. Dilansir dari World Wide Fund for Nature (WWF), sebesar 30-40% dari semua kayu industri global digunakan untuk memenuhi permintaan produk berbasis kertas, seperti kertas katalog kantor, buku, kertas glossy, tisu, hingga kemasan produk.\n\n',
                      ),
                      TextSpan(
                          text:
                              'Selain itu, industri pulp dan kertas menggunakan sumber daya alam lain yang cukup besar, seperti air. Menurut Environment Canada, untuk memproduksi 1 kg kertas dibutuhkan setidaknya 324 liter air. Bahkan kertas berukuran A4 yang keriting sekalipun telah menelan hingga 20 liter air selama proses produksinya. Dilansir dari Environmental Paper Network (2018), Industri pulp dan kertas di beberapa negara telah menggunakan 10% persediaan air tawar untuk memproduksi kertas. \n\n'),
                      TextSpan(
                        text:
                            'Di tahun 2018 sampah kertas telah mengambil 40% bagian di Tempat Pembuangan Akhir. Hal ini tentunya akan menimbulkan dampak buruk bagi lingkungan dan berdampak pada kehidupan manusia. Sampah kertas sebenarnya dapat terurai dengan tanah. Namun, proses penguraian kertas biasanya memakan waktu 3-6 bulan tergantung dengan kondisi tanahnya.\n\n',
                      ),
                      TextSpan(
                        text:
                            'Akan tetapi, proses penguraian kertas  tentu harus diawali dengan pemilahan. Tanpa pemilahan, sampah kertas dapat mempercepat terjadinya perubahan iklim. Kertas yang bersifat organik dapat bercampur dengan sampah tipe lain, yaitu anorganik. Hal tersebut akan membuat pembusukan berlangsung tanpa oksigen atau anaerob. Pembusukan yang berlangsung secara anaerob itu akan menghasilkan gas metana. Gas metana dapat mempercepat perubahan iklim karena memiliki kekuatan menangkap panas di atmosfer bumi 25 kali lebih kuat dibandingkan karbondioksida. \n',
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

  void _showMetalModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: 'Sampah Metal',
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
                          'https://firebasestorage.googleapis.com/v0/b/gemastik-407fd.appspot.com/o/material_images%2FB55C3C50-1122-4BEC-8843-24F10A4A09CE_w1200_r1.jpg?alt=media&token=ae1f49d2-f459-4cf9-9ff7-cea93cf164d7',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                // Informasi tentang sampah metal
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
                            'Sampah metal adalah salah satu jenis sampah yang sulit terurai. Beberapa jenis metal kecil, seperti kaleng timah, dapat berkarat dan mengelupas menjadi atmosfer setelah sekitar 100 tahun. Namun, potongan metal yang lebih besar dan metal yang tidak rentan terhadap karat tidak terurai1.\n\n',
                      ),
                      TextSpan(
                          text:
                              'Dunia menghasilkan miliaran ton sampah metal setiap tahun. Pencemaran metal berat telah muncul karena aktivitas manusia, terutama karena penambangan metal, peleburan, pengecoran, dan industri lain yang berbasis metal, pelindian metal dari berbagai sumber seperti tempat pembuangan sampah, tempat pembuangan limbah, ekskresi, kotoran ternak dan ayam, aliran permukaan, mobil dan pekerjaan jalan.\n\n'),
                      TextSpan(
                        text:
                            'Kontaminasi lingkungan juga dapat terjadi melalui korosi metal, deposisi atmosferik, erosi tanah ion metal dan pelindian metal berat, penangguhan kembali sedimen dan penguapan metal dari sumber air ke tanah dan air tanah3.\n\n',
                      ),
                      TextSpan(
                        text:
                            'Salah satu langkah efektif untuk mengatasi masalah sampah metal adalah daur ulang metal. Dengan demikian, kita dapat menggunakan sumber daya kita dengan lebih efisien dan juga mengurangi beberapa jenis masalah lingkungan\n',
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

  void _showCardBoardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: 'Sampah Kardus',
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
                          'https://firebasestorage.googleapis.com/v0/b/gemastik-407fd.appspot.com/o/material_images%2Fimage-235.png?alt=media&token=83225b0b-a7e4-4bf7-b612-f434ce4523bd',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                // Informasi tentang sampah kardus
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
                            'Kardus terbuat dari kertas atau karton dan dikategorikan sebagai sampah organik sehingga dapat terurai secara alami di alam. Namun, segala jenis material kertas membutuhkan waktu yang cukup lama hingga beberapa bulan untuk akhirnya hancur sepenuhnya. Menurut estimasi, ada 6 juta paket yang dikirimkan di Indonesia.\n\n',
                      ),
                      TextSpan(
                          text:
                              'Sampah kardus yang tidak terurus bisa menjadi sarang kuman penyebab penyakit. Namun, jika limbah kardus dibersihkan maka akan menyebabkan berbagai masalah seperti sarang tikus, banjir dan lain lain.\n\n'),
                      TextSpan(
                        text:
                            'Salah satu langkah efektif untuk mengatasi masalah sampah kardus adalah daur ulang kardus. Pisahkan kardus dari bahan pembungkus lain di dalamnya, seperti gabus polystyrene (StyrofoamTM), busa, plastik, dan tali. Bongkar dan lipat kardus untuk menghemat tempat, lalu ikat bertumpuk dengan kardus bekas lain. Kardus yang didaur ulang dapat berguna untuk kemudian dijadikan bubur kertas lagi dan dibuat menjadi kardus baru, sehingga selain mengurangi sampah, kardus daur ulang juga dapat mengurangi pohon yang harus ditebang untuk membuat bubur kertas.\n\n',
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

  void _showBatteryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: 'Sampah Baterai',
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
                          'https://firebasestorage.googleapis.com/v0/b/gemastik-407fd.appspot.com/o/material_images%2Fbaterai_2.jpg?alt=media&token=a483d6a9-2198-479f-890e-d5b16bb3ad39',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                // Informasi tentang sampah baterai
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
                            'Sampah baterai termasuk dalam kategori sampah B3 (Bahan Berbahaya & Beracun), karena di dalamnya mengandung berbagai logam berat, seperti merkuri, mangan, timbal, kadmium, nikel dan lithium, yang berbahaya bagi lingkungan dan kesehatan kita.\n\n',
                      ),
                      TextSpan(
                          text:
                              'Waktu terurai baterai tergantung pada jenis baterai. Misalnya, baterai alkaline umumnya membutuhkan waktu antara 100 hingga 1.000 tahun untuk terurai sepenuhnya.\n\n'),
                      TextSpan(
                        text:
                            'Menurut perkiraan terbaru, setiap tahunnya diproduksi sekitar 55 juta ton baterai di seluruh dunia. Sayangnya, sebagian besar baterai yang dibuang tidak didaur ulang dengan benar dan berakhir di tempat pembuangan sampah, menyebabkan masalah lingkungan yang serius.\n\n',
                      ),
                      TextSpan(
                        text:
                            'Dampak terhadap lingkungan : Sampah baterai dapat memiliki dampak yang merugikan terhadap lingkungan. Baterai yang dibuang secara tidak benar dapat mengandung zat-zat berbahaya seperti merkuri, timbal, kadmium, dan logam berat lainnya. Jika baterai tersebut bocor atau terurai, zat-zat berbahaya tersebut dapat mencemari tanah, air tanah, dan sumber air permukaan, mengancam kehidupan organisme dan menyebabkan polusi lingkungan.\n\n',
                      ),
                      TextSpan(
                        text: 'Cara membuang : \n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            '1. Tempatkan baterai bekas pada tempat terpisah dari sampah lain\n\n',
                      ),
                      TextSpan(
                        text:
                            '2. Pasang selotip bening yang tak konduktif pada kedua ujung baterai\n\n',
                      ),
                      TextSpan(
                        text:
                            '3. Masukkan baterai bekas dalam plastik atau wadah khusus yang tidak bersifat konduktif\n\n',
                      ),
                      TextSpan(
                        text:
                            '4. Cari lokasi fasilitas pengolahan limbah B3 terdekat\n',
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          title: 'Sampah Organik',
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
                          'https://firebasestorage.googleapis.com/v0/b/gemastik-407fd.appspot.com/o/material_images%2F22052018091450_1.jpg?alt=media&token=93d940af-42f6-4775-840a-3f7866d9b7ee',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                // Informasi tentang sampah organik
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
                            'Sampah organik adalah jenis sampah yang berasal dari sisa-sisa organisme hidup, seperti sisa makanan, dedaunan, dan bahan-bahan alami lainnya. Sampah organik cenderung terurai dengan relatif cepat dibandingkan dengan sampah non-organik. Waktu terurai sampah organik dapat bervariasi tergantung pada kondisi lingkungan, suhu, dan kelembaban. Umumnya, sampah organik dapat terurai dalam rentang waktu beberapa minggu hingga beberapa bulan.\n\n',
                      ),
                      TextSpan(
                        text:
                            'Jumlah sampah organik di dunia sangat besar. Diperkirakan bahwa sekitar 50-60% dari total limbah yang dihasilkan oleh rumah tangga merupakan sampah organik. Data yang spesifik mengenai jumlah sampah organik di dunia secara keseluruhan sulit diperoleh, karena jumlahnya dapat bervariasi tergantung pada populasi, kebiasaan konsumsi, dan praktik pengelolaan sampah di setiap negara.\n\n',
                      ),
                      TextSpan(
                        text:
                            'Ketika sampah organik terbuang ke dalam tempat pembuangan sampah biasa, seperti tumpukan sampah di landfill, dampak terhadap lingkungan bisa signifikan. Sampah organik yang terkubur dalam kondisi yang tidak ada atau terbatasnya oksigen menghasilkan gas metana, yang merupakan gas rumah kaca yang berkontribusi terhadap perubahan iklim. Selain itu, pembusukan sampah organik juga dapat menghasilkan air lindi yang mengandung zat-zat yang mencemari tanah dan sumber air.\n\n',
                      ),
                      TextSpan(
                        text: 'Cara daur ulang :\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            '1. Kompos: Sampah organik dapat didaur ulang menjadi kompos melalui proses pengomposan. Dalam proses ini, sampah organik ditempatkan dalam kondisi yang sesuai, seperti tumpukan kompos atau kotak kompos, di mana mikroorganisme menguraikan bahan organik menjadi humus kaya nutrisi yang dapat digunakan sebagai pupuk alami.\n\n',
                      ),
                      TextSpan(
                        text:
                            '2. Vermikompos: Metode ini melibatkan penggunaan cacing tanah untuk mendaur ulang sampah organik. Cacing tanah memakan bahan organik, mencernanya, dan menghasilkan vermikompos yang kaya akan nutrisi.\n\n',
                      ),
                      TextSpan(
                        text:
                            '3. Energi terbarukan: Beberapa teknologi juga memungkinkan konversi sampah organik menjadi energi terbarukan seperti biogas. Proses ini melibatkan penguraian sampah organik dalam kondisi anaerobik, menghasilkan biogas yang dapat digunakan sebagai sumber energi.\n\n',
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          title: 'Sampah Elektronik',
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
                          'https://firebasestorage.googleapis.com/v0/b/gemastik-407fd.appspot.com/o/material_images%2Flarge-shutterstock-1545599141-8f44889754105cd8bebca15578fc5fab.jpg?alt=media&token=ced53ade-7cff-42b3-b107-50d7166c6b81',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                // Informasi tentang sampah elektronik
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
                            'Sampah elektronik, juga dikenal sebagai e-waste, terdiri dari perangkat elektronik yang sudah tidak terpakai atau rusak. Proses terurai sampah elektronik sangat bervariasi tergantung pada jenis dan komponen yang ada di dalamnya. Beberapa komponen dapat terurai dalam waktu yang lebih singkat, sementara yang lain bisa membutuhkan waktu yang sangat lama. Beberapa komponen elektronik, seperti logam berat, plastik, dan bahan kimia berbahaya, dapat bertahan dalam lingkungan selama bertahun-tahun.\n\n',
                      ),
                      TextSpan(
                        text:
                            'Jumlah sampah elektronik yang dihasilkan di dunia terus meningkat dengan cepat. Setiap tahunnya, diperkirakan ada lebih dari 50 juta ton sampah elektronik yang dihasilkan secara global. Jumlah ini dipengaruhi oleh perkembangan teknologi yang terus berlanjut dan pola konsumsi perangkat elektronik yang tinggi. Sayangnya, hanya sebagian kecil sampah elektronik yang didaur ulang dengan benar.\n\n',
                      ),
                      TextSpan(
                        text:
                            'Sampah elektronik dapat memiliki dampak yang merugikan terhadap lingkungan jika tidak dikelola dengan benar. Bahan kimia berbahaya yang terkandung dalam elektronik, seperti merkuri, timbal, kadmium, dan bahan bakar fosil, dapat mencemari tanah, air, dan udara jika terbuang secara tidak benar. Pemrosesan yang tidak tepat juga dapat menyebabkan emisi gas rumah kaca dan pencemaran lingkungan lainnya.\n\n',
                      ),
                      TextSpan(
                        text: 'Cara membuang sampah :\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            '1. Kumpulkan barang elektronik yang sudah tidak terpakai di satu tempat. Ingat, jangan buang ke tempah sampah yang menampung sampah rumah tangga.\n\n',
                      ),
                      TextSpan(
                        text:
                            '2. Pilih sampah elektronik berdasarkan jenisnya supaya pengelolaannya bisa lebih mudah.\n\n',
                      ),
                      TextSpan(
                        text:
                            '3. Cari lokasi fasilitas pengolahan atau daur ulang sampah elektronik, pastikan fasilitas itu memiliki izin mengelola limbah elektronik sesuai standar dan prosedur yang telah ditetapkan, mulai dari tahapan pengumpulan, pengangkutan, pemilahan sampai ke proses pendaurulangan dan pemusnahan.\n\n',
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          title: 'Sampah Medis',
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
                          'https://firebasestorage.googleapis.com/v0/b/gemastik-407fd.appspot.com/o/material_images%2F5e9d820f86ec6224113220.jpg?alt=media&token=13237850-548d-4ac8-be30-2a3d162969e2',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                // Informasi tentang sampah medis
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
                            'Sampah medis termasuk dalam kategori limbah berbahaya dan tidak dapat terurai dengan cepat secara alami. Waktu terurai sampah medis sangat bervariasi tergantung pada jenis limbah medis yang ada di dalamnya. Beberapa bahan limbah medis mungkin membutuhkan waktu bertahun-tahun atau bahkan dekade untuk terurai sepenuhnya.\n\n',
                      ),
                      TextSpan(
                        text:
                            'Jumlah sampah medis yang dihasilkan di seluruh dunia cukup signifikan. Organisasi Kesehatan Dunia (WHO) memperkirakan bahwa sekitar 16 miliar jarum suntik digunakan setiap tahunnya. Selain itu, ada juga limbah medis lainnya seperti perban, sarung tangan, botol obat, alat bedah, dan bahan kimia medis. Namun, jumlah pasti sampah medis secara global sulit ditentukan karena faktor-faktor seperti populasi, fasilitas kesehatan, dan praktik pengelolaan limbah medis yang berbeda di setiap negara.\n\n',
                      ),
                      TextSpan(
                        text:
                            'Sampah medis dapat memiliki dampak negatif terhadap lingkungan jika tidak dikelola dengan benar. Limbah medis yang tidak diolah secara tepat dapat mencemari air, tanah, dan udara. Bahan kimia berbahaya, infeksius, atau bahan radioaktif dalam sampah medis dapat menyebabkan pencemaran yang serius dan berdampak negatif pada organisme hidup dan ekosistem.\n\n',
                      ),
                      TextSpan(
                        text: 'Cara membuang sampah :\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            '1. Pisahkan dan kemas dengan aman: Pisahkan sampah medis dari sampah lainnya sejak awal. Kemas limbah medis secara aman dalam wadah yang tahan bocor, tahan tusukan, dan berlabel jelas sebagai limbah medis.\n\n',
                      ),
                      TextSpan(
                        text:
                            '2. Identifikasi dan kategorikan: Identifikasi dan kategorikan limbah medis sesuai dengan pedoman pengelolaan limbah medis yang berlaku di wilayah Anda. Limbah medis mungkin terdiri dari limbah tajam, limbah infeksius, limbah kimia, atau limbah farmasi.\n\n',
                      ),
                      TextSpan(
                        text:
                            '3. Gunakan jasa pengelolaan limbah medis terpercaya: Cari tahu tentang jasa pengelolaan limbah medis yang terpercaya di wilayah Anda. Jasa ini akan membantu mengumpulkan, mengangkut, dan membuang limbah medis dengan aman dan sesuai dengan peraturan yang berlaku.\n\n',
                      ),
                      TextSpan(
                        text:
                            '4. Jangan membakar atau membuang ke lingkungan: Hindari membakar atau membuang sampah medis ke lingkungan. Hal ini dapat menyebabkan pencemaran lingkungan dan penyebaran penyakit.\n\n',
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                      'Metal',
                      'Kaca',
                      'Kertas',
                      'Kardus'
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
