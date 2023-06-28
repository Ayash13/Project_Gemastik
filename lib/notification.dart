import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      setState(() {
        transactionHistoryList = transactions;
      });
    }).catchError((error) {
      print('Error fetching transaction history: $error');
      // Show an error message or handle the error accordingly
    });
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
      appBar: AppBar(
        title: Text('Transaction History'),
      ),
      body: ListView.builder(
        itemCount: transactionHistoryList.length,
        itemBuilder: (context, index) {
          final transaction = transactionHistoryList[index];
          final monthName = getMonthName(transaction.month);
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        '$monthName',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(255, 20, 20, 20),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.5, color: Colors.black),
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromARGB(179, 255, 141, 75),
                      ),
                      child: Center(
                        child: Text(
                          '${transaction.date}',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 20, 20, 20),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.black),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
