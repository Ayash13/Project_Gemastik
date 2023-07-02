import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:project_gemastik/invoice.dart';

class NotifiCation extends StatefulWidget {
  const NotifiCation({super.key});

  @override
  State<NotifiCation> createState() => _NotifiCationState();
}

class _NotifiCationState extends State<NotifiCation> {
  DateTime time = DateTime.now();

  int date = 0;
  int month = 0;
  List<dynamic> products = [];
  int shippingPrice = 0;
  double totalPrice = 0;
  String paymentMethod = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TransactionHistoryScreen(),
    );
  }
}

class TransactionHistory {
  final List<dynamic> address;
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime time;
  final int date;
  final int month;
  final List<dynamic> products;
  final int shippingPrice;
  final double totalPrice;
  final String paymentMethod;
  final String status;

  TransactionHistory({
    required this.address,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.time,
    required this.date,
    required this.month,
    required this.products,
    required this.shippingPrice,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
  });

  factory TransactionHistory.fromMap(Map<String, dynamic> map) {
    return TransactionHistory(
      id: map['id'],
      address: List<dynamic>.from(['address']),
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      time: map['time'].toDate(),
      date: map['date'],
      month: map['month'],
      products: List<dynamic>.from(map['products']),
      shippingPrice: map['shippingPrice'],
      totalPrice: map['totalPrice'],
      paymentMethod: map['paymentMethod'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'date': date,
      'month': month,
      'products': products,
      'shippingPrice': shippingPrice,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
    };
  }
}

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<TransactionHistory> transactionHistoryList = [];

  @override
  void initState() {
    super.initState();
    fetchTransactionHistory();
  }

  void fetchTransactionHistory() {
    // Get the current user
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    // Get the reference to the user's transactions collection
    final userTransactionsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('transactions');

    // Fetch the transaction history from Firestore
    userTransactionsRef.get().then((querySnapshot) {
      final List<TransactionHistory> transactions = [];
      querySnapshot.docs.forEach((doc) {
        final transactionData = doc.data() as Map<String, dynamic>;
        final transaction = TransactionHistory.fromMap(transactionData);
        transactions.add(transaction);
      });

      // Sort the transactions based on the date in descending order
      transactions.sort((a, b) => b.time.compareTo(a.time));

      setState(() {
        transactionHistoryList = transactions;
      });
    }).catchError((error) {
      print('Error fetching transaction history: $error');
      // Show an error message or handle the error accordingly
    });
  }

  Future<void> _openDatePicker(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      List<TransactionHistory> sortedList =
          transactionHistoryList.where((transaction) {
        final transactionDate =
            DateTime.fromMillisecondsSinceEpoch(transaction.date);
        final selectedDateTime =
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        return transactionDate.isAtSameMomentAs(selectedDateTime);
      }).toList();

      sortedList.sort((a, b) => a.date.compareTo(b.date));

      setState(() {
        // Update the transactionHistoryList with the sorted list
        transactionHistoryList = sortedList;
      });
    }
  }

  String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              child: Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color.fromARGB(160, 255, 219, 153),
                  border: Border.all(width: 2, color: Colors.black),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30,
                    left: 20,
                    right: 20,
                    bottom: 10,
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
                        'Transaction History',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 20, 20, 20),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _openDatePicker(context);
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.black),
                            borderRadius: BorderRadius.circular(30),
                            color: Color.fromARGB(160, 126, 186, 148),
                          ),
                          child: Icon(MdiIcons.calendarMonth),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: transactionHistoryList.length,
                    itemBuilder: (context, index) {
                      final transaction = transactionHistoryList[index];
                      final monthName = getMonthName(transaction.month);
                      final products = transaction.products;

                      return GestureDetector(
                        onTap: () {
                          // Navigate to the Confirm Payment page with the transaction data
                          Get.to(
                            InvoicePage(transactionHistory: transaction),
                          );
                        },
                        child: Stack(
                          children: [
                            Positioned(
                              top: 15,
                              left: 38,
                              child: Container(
                                width: 2.5,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 15,
                              right: 38,
                              child: Container(
                                width: 2.5,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 20,
                                    left: 20,
                                    right: 20,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2, color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color.fromARGB(
                                              255, 252, 163, 111),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$monthName',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(
                                                  255, 20, 20, 20),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 2,
                                              color: const Color.fromARGB(
                                                  255, 79, 75, 75),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.white,
                                          ),
                                          child: Center(
                                            child: Text(
                                              transaction.id,
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: const Color.fromARGB(
                                                    255, 20, 20, 20),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2, color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color.fromARGB(
                                              255, 252, 163, 111),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${transaction.date}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(
                                                  255, 20, 20, 20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 50,
                                    left: 20,
                                    right: 20,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2,
                                        color: Colors.black,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Column(
                                        children: [
                                          SizedBox(height: 10),
                                          Theme(
                                            data: Theme.of(context).copyWith(
                                                dividerColor:
                                                    Colors.transparent),
                                            child: ExpansionTileTheme(
                                              data: ExpansionTileThemeData(
                                                iconColor: Colors.black,
                                                textColor: Colors.black,
                                                collapsedIconColor:
                                                    Colors.black,
                                                collapsedTextColor:
                                                    Colors.black,
                                              ),
                                              child: ExpansionTile(
                                                title: Row(
                                                  children: [
                                                    // Product image
                                                    Container(
                                                      height: 100,
                                                      width: 80,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 2,
                                                            color:
                                                                Colors.black),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Card(
                                                        clipBehavior: Clip
                                                            .antiAliasWithSaveLayer,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        elevation: 0,
                                                        child: Image.network(
                                                          products
                                                              .first['image']
                                                              .first
                                                              .toString(),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    // Product details
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            products.first[
                                                                'product'],
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          Divider(
                                                            thickness: 1.5,
                                                            color: Colors.black,
                                                            endIndent: 20,
                                                          ),
                                                          Text(
                                                            'Price: Rp${products.first['price'].toStringAsFixed(0)}',
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Quantity: ${products.first['quantity']}',
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                children: products
                                                    .sublist(1)
                                                    .map((product) {
                                                  final List<dynamic>
                                                      productImage =
                                                      product['image'];
                                                  final double productPrice =
                                                      product['price'];
                                                  final String productName =
                                                      product['product'];
                                                  final int quantity =
                                                      product['quantity'];

                                                  return Column(
                                                    children: [
                                                      Divider(
                                                        thickness: 2,
                                                        color: Colors.black,
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 15),
                                                        child: Row(
                                                          children: [
                                                            // Product image
                                                            Container(
                                                              height: 100,
                                                              width: 80,
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    width: 2,
                                                                    color: Colors
                                                                        .black),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              child: Card(
                                                                clipBehavior: Clip
                                                                    .antiAliasWithSaveLayer,
                                                                child: Image
                                                                    .network(
                                                                  productImage
                                                                      .first
                                                                      .toString(),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            // Product details
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    productName,
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                  Divider(
                                                                    thickness:
                                                                        1.5,
                                                                    color: Colors
                                                                        .black,
                                                                    endIndent:
                                                                        85,
                                                                  ),
                                                                  Text(
                                                                    'Price: Rp${productPrice.toStringAsFixed(0)}',
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    'Quantity: ${quantity}',
                                                                    style: GoogleFonts
                                                                        .poppins(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
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
                                          Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 2,
                                                  color: Colors.black,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Color.fromARGB(
                                                    255, 140, 203, 255),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "View Invoice",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TrashCan extends StatefulWidget {
  const TrashCan({super.key});

  @override
  State<TrashCan> createState() => _TrashCanState();
}

class _TrashCanState extends State<TrashCan> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
