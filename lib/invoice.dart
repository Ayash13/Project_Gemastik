import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_gemastik/notification.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ticket_widget/ticket_widget.dart';

class InvoicePage extends StatefulWidget {
  final TransactionHistory transactionHistory;

  const InvoicePage({Key? key, required this.transactionHistory})
      : super(key: key);

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '_')
        .replaceAll(':', '_');
    final name = 'invoice_$time';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    return result['filepath'];
  }

  Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color.fromARGB(255, 105, 175, 233),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(top: 40),
              width: MediaQuery.of(context).size.width * 0.90,
              height: MediaQuery.of(context).size.height * 0.05,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: MediaQuery.of(context).size.height * 0.05,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black),
                        borderRadius: BorderRadius.circular(40),
                        color: Color.fromARGB(255, 255, 231, 195),
                      ),
                      child: Center(
                        child: Icon(MdiIcons.closeCircle),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.05,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black),
                        borderRadius: BorderRadius.circular(40),
                        color: Color.fromARGB(255, 255, 231, 195),
                      ),
                      child: Center(
                        child: Text(
                          'Order Details',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 20, 20, 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () async {
                      final screenShotController = ScreenshotController();
                      final image =
                          await screenShotController.captureFromWidget(
                        MediaQuery(
                          data: MediaQueryData(),
                          child: Material(
                            child: Container(
                              color: Color.fromARGB(255, 105, 175, 233),
                              height: 730,
                              width: 400,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: invoiceWidget(context),
                              ),
                            ),
                          ),
                        ),
                      );
                      if (image == null) return;
                      saveImage(image).then(
                        (value) => Get.snackbar(
                          'Success',
                          'Invoice saved to your gallery',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Color.fromARGB(240, 126, 186, 148),
                          colorText: Colors.black,
                          duration: Duration(seconds: 3),
                          margin: EdgeInsets.all(10),
                          borderRadius: 10,
                          borderColor: Colors.black,
                          borderWidth: 1.5,
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: MediaQuery.of(context).size.height * 0.05,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black),
                        borderRadius: BorderRadius.circular(40),
                        color: Color.fromARGB(255, 255, 231, 195),
                      ),
                      child: Center(
                        child: Icon(MdiIcons.download),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            layoutWidget(context)
          ],
        ),
      ),
    );
  }

  Widget layoutWidget(BuildContext conntext) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                invoiceWidget(context),
                if (widget.transactionHistory.status == "Waiting for payment")
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 248, 235),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              border:
                                  Border.all(width: 1.5, color: Colors.black),
                            ),
                            child: bottomSheet(context),
                          ),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.black),
                          borderRadius: BorderRadius.circular(20),
                          color: Color.fromARGB(255, 255, 231, 195),
                        ),
                        child: Center(
                          child: Text(
                            'Confirm Payment',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 20, 20, 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.transactionHistory.status == "Payment success")
                  SizedBox(
                    height: 20,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget bottomSheet(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
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
                    height: 500,
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
                Expanded(
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
                      decoration: BoxDecoration(
                        border: Border.all(width: 2.0, color: Colors.black),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      height: 500,
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  if (_image != null) {
                    final transactionData = {
                      'id': widget.transactionHistory.id,
                      'deliveryStatus':
                          widget.transactionHistory.deliveryStatus,
                      'receiptNumber': widget.transactionHistory.receiptNumber,
                      'addressTitle': widget.transactionHistory.addressTitle,
                      'addressRoadNumber':
                          widget.transactionHistory.addressRoadNumber,
                      'addressCity': widget.transactionHistory.addressCity,
                      'addressProvince':
                          widget.transactionHistory.addressProvince,
                      'name':
                          FirebaseAuth.instance.currentUser?.displayName ?? '',
                      'email': FirebaseAuth.instance.currentUser?.email ?? '',
                      'phone': widget.transactionHistory.phone,
                      'time': widget.transactionHistory.time,
                      'date': widget.transactionHistory.date,
                      'month': widget.transactionHistory.month,
                      'products': widget.transactionHistory.products,
                      'shippingPrice': 0,
                      'totalPrice': widget.transactionHistory.totalPrice,
                      'paymentMethod': widget.transactionHistory.paymentMethod,
                      'status': widget.transactionHistory.status,
                    };

                    final User? currentUser = FirebaseAuth.instance.currentUser;
                    final userTransactionsRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser!.uid)
                        .collection('transactions');

                    userTransactionsRef
                        .doc(widget.transactionHistory.id)
                        .set(transactionData)
                        .then((_) {
                      final storageRef = FirebaseStorage.instance.ref().child(
                          'transaction_images/${widget.transactionHistory.id}.jpg');

                      storageRef
                          .putFile(_image!)
                          .then((TaskSnapshot snapshot) async {
                        final imageUrl = await snapshot.ref.getDownloadURL();

                        userTransactionsRef
                            .doc(widget.transactionHistory.id)
                            .update({
                          'status': 'Payment success',
                          'proofImage': imageUrl,
                        }).then((_) {
                          Navigator.pop(context);
                          Get.snackbar(
                            'Success',
                            'Please wait for us to verify your payment',
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
                          print('Error updating status: $error');
                        });
                      }).catchError((error) {
                        print('Error uploading image: $error');
                      });
                    }).catchError((error) {
                      print('Error creating document: $error');
                    });
                  }
                },
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.black),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      'I have transferred',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 20, 20, 20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget invoiceWidget(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return TicketWidget(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 710,
          isCornerRounded: true,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('yyyy-MM-dd')
                                .format(widget.transactionHistory.time),
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 26),
                          Text(
                            'Invoice',
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 30),
                          Text(
                            DateFormat('HH:mm:ss')
                                .format(widget.transactionHistory.time),
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: List.generate(
                          126 ~/ 2,
                          (index) => Expanded(
                            child: Container(
                              color: index % 2 == 0
                                  ? Colors.transparent
                                  : Colors.black,
                              height: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Name :',
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            widget.transactionHistory.name,
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Phone :',
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            widget.transactionHistory.phone,
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Email :',
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            widget.transactionHistory.email,
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Address :',
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            //address title
                            widget.transactionHistory.addressTitle,
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment :',
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            widget.transactionHistory.paymentMethod,
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  126 ~/ 2,
                  (index) => Expanded(
                    child: Container(
                      color: index % 2 == 0 ? Colors.transparent : Colors.black,
                      height: 2,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product :',
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 100,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: widget.transactionHistory.products
                                      .map((product) {
                                    final productName = product['product'];
                                    final productQuantity = product['quantity'];
                                    final productPrice = product['price'];

                                    return Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 5,
                                          ),
                                          child: Text(
                                            '* $productName ($productQuantity) x \Rp${productPrice.toStringAsFixed(0)}',
                                            style: GoogleFonts.sourceCodePro(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal :',
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            'Rp${widget.transactionHistory.totalPrice.toStringAsFixed(0)}',
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Shipping :',
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            'Rp0',
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total :',
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            'Rp${widget.transactionHistory.totalPrice.toStringAsFixed(0)}',
                            style: GoogleFonts.sourceCodePro(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: List.generate(
                          126 ~/ 2,
                          (index) => Expanded(
                            child: Container(
                              color: index % 2 == 0
                                  ? Colors.transparent
                                  : Colors.black,
                              height: 2,
                            ),
                          ),
                        ),
                      ),
                      if (widget.transactionHistory.status == "Payment success")
                        SizedBox(
                          height: 20,
                        )
                      else
                        SizedBox(
                          height: 12,
                        ),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              widget.transactionHistory.status,
                              style: GoogleFonts.sourceCodePro(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (widget.transactionHistory.status ==
                                "Waiting for payment")
                              Text(
                                "Please transfer to : BCA (8421184747)",
                                style: GoogleFonts.sourceCodePro(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
