import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:project_gemastik/notification.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  void updateTransactionDetails(String userId, String transactionId,
      String updatedDeliveryStatus, String updatedReceiptNumber) {
    final userTransactionsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions');

    userTransactionsRef.doc(transactionId).update({
      'deliveryStatus': updatedDeliveryStatus,
      'receiptNumber': updatedReceiptNumber,
    }).then((_) {
      print('Transaction details updated successfully.');
    }).catchError((error) {
      print('Error updating transaction details: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 30,
          ),
          child: Column(
            children: [
              Row(
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
                    'Transactions',
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
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collectionGroup('transactions')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Error fetching transactions');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: const CircularProgressIndicator());
                    }

                    final transactions = snapshot.data?.docs;

                    return ListView.builder(
                      itemCount: transactions?.length ?? 0,
                      itemBuilder: (context, index) {
                        final transactionData = transactions?[index].data()
                            as Map<String, dynamic>?;

                        if (transactionData == null) {
                          return const SizedBox(); // Handle the case where transactionData is null
                        }

                        final userId =
                            transactions?[index].reference.parent.parent?.id;
                        final transaction =
                            TransactionHistory.fromMap(transactionData);
                        final products = transaction.products;

                        return Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 25, bottom: 25),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                border: Border.all(
                                  width: 2,
                                  color: Colors.black,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  top: 30,
                                  bottom: 10,
                                ),
                                child: Column(
                                  children: [
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: ExpansionTileTheme(
                                        data: ExpansionTileThemeData(
                                          iconColor: Colors.black,
                                          textColor: Colors.black,
                                          collapsedIconColor: Colors.black,
                                          collapsedTextColor: Colors.black,
                                        ),
                                        child: ExpansionTile(
                                          tilePadding: EdgeInsets.all(0),
                                          title: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Product: ',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 20, 20, 20),
                                                    ),
                                                  ),
                                                  Text(
                                                    products.first['product'],
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 20, 20, 20),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Quantity: ',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 20, 20, 20),
                                                    ),
                                                  ),
                                                  Text(
                                                    'X ${products.first['quantity'].toStringAsFixed(0)}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 20, 20, 20),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Price: ',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 20, 20, 20),
                                                    ),
                                                  ),
                                                  Text(
                                                    'Rp${products.first['price'].toStringAsFixed(0)}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 20, 20, 20),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 2,
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                          children: products
                                              .sublist(1)
                                              .map<Widget>((product) {
                                            final double productPrice =
                                                product['price'];
                                            final String productName =
                                                product['product'];
                                            final int quantity =
                                                product['quantity'];

                                            return Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Product: ',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: const Color
                                                                .fromARGB(
                                                            255, 20, 20, 20),
                                                      ),
                                                    ),
                                                    Text(
                                                      productName,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: const Color
                                                                .fromARGB(
                                                            255, 20, 20, 20),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Quantity: ',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: const Color
                                                                .fromARGB(
                                                            255, 20, 20, 20),
                                                      ),
                                                    ),
                                                    Text(
                                                      'X ${quantity.toStringAsFixed(0)}',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: const Color
                                                                .fromARGB(
                                                            255, 20, 20, 20),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Price: ',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: const Color
                                                                .fromARGB(
                                                            255, 20, 20, 20),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Rp${productPrice.toStringAsFixed(0)}',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: const Color
                                                                .fromARGB(
                                                            255, 20, 20, 20),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Divider(
                                                  thickness: 2,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Name : ',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: const Color.fromARGB(
                                                255, 20, 20, 20),
                                          ),
                                        ),
                                        Text(
                                          transaction.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(
                                                255, 20, 20, 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Address : ',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: const Color.fromARGB(
                                                255, 20, 20, 20),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${transaction.addressProvince},',
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                                color: const Color.fromARGB(
                                                    255, 20, 20, 20),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              '${transaction.addressCity},',
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                                color: const Color.fromARGB(
                                                    255, 20, 20, 20),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              transaction.addressRoadNumber,
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                                color: const Color.fromARGB(
                                                    255, 20, 20, 20),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Time : ',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: const Color.fromARGB(
                                                255, 20, 20, 20),
                                          ),
                                        ),
                                        Text(
                                          //year, month, date, hour, sec
                                          '${transaction.time.year}-${transaction.time.month}-${transaction.time.day} ${transaction.time.hour}:${transaction.time.minute}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(
                                                255, 20, 20, 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Delivery Status : ',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: const Color.fromARGB(
                                                255, 20, 20, 20),
                                          ),
                                        ),
                                        Text(
                                          transaction.deliveryStatus,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(
                                                255, 20, 20, 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Receipt number : ',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: const Color.fromARGB(
                                                255, 20, 20, 20),
                                          ),
                                        ),
                                        Text(
                                          transaction.receiptNumber,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(
                                                255, 20, 20, 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.dialog(GestureDetector(
                                          onTap: () {
                                            Get.back();
                                          },
                                          child: Image.network(
                                            transaction.proofImage,
                                            fit: BoxFit.cover,
                                          ),
                                        ));
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 140, 203, 255),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            width: 2,
                                            color: Colors.black,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              offset: Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            'See Payment Proof',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: const Color.fromARGB(
                                                  255, 20, 20, 20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            String updatedDeliveryStatus =
                                                transaction.deliveryStatus;
                                            String updatedReceiptNumber =
                                                transaction.receiptNumber;

                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                                side: BorderSide(
                                                    width: 1.5,
                                                    color: Colors.black),
                                              ),
                                              backgroundColor: Color.fromARGB(
                                                  255, 255, 251, 235),
                                              title: Center(
                                                child: Text(
                                                  'Update Transaction Status',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color.fromARGB(
                                                        255, 20, 20, 20),
                                                  ),
                                                ),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          'Delivery Status',
                                                    ),
                                                    onChanged: (value) {
                                                      updatedDeliveryStatus =
                                                          value;
                                                    },
                                                  ),
                                                  TextField(
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          'Receipt Number',
                                                    ),
                                                    onChanged: (value) {
                                                      updatedReceiptNumber =
                                                          value;
                                                    },
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.black,
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Color.fromARGB(
                                                        193, 225, 156, 156),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Color.fromARGB(
                                                        150, 126, 186, 148),
                                                  ),
                                                  child: TextButton(
                                                    child: Text(
                                                      'Update',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      //update function
                                                      updateTransactionDetails(
                                                        userId!,
                                                        transaction.id,
                                                        updatedDeliveryStatus,
                                                        updatedReceiptNumber,
                                                      );
                                                      Navigator.of(context)
                                                          .pop(); // Close the dialog.
                                                    },
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 140, 203, 255),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            width: 2,
                                            color: Colors.black,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              offset: Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Update',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: const Color.fromARGB(
                                                  255, 20, 20, 20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: 40,
                                  right: 40,
                                ),
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.black,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    transaction.id,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          const Color.fromARGB(255, 20, 20, 20),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
