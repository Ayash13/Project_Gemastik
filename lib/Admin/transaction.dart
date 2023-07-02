import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_gemastik/notification.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Page'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('transactions').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error fetching transactions');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final transactions = snapshot.data?.docs;

          return ListView.builder(
            itemCount: transactions?.length ?? 0,
            itemBuilder: (context, index) {
              final transactionData =
                  transactions?[index].data() as Map<String, dynamic>;
              final transaction = TransactionHistory.fromMap(transactionData);

              return ListTile(
                title: Text('Transaction ID: ${transaction.id}'),
                subtitle: Text('Total Price: ${transaction.totalPrice}'),
                onTap: () {
                  // Handle tap on a specific transaction
                },
              );
            },
          );
        },
      ),
    );
  }
}
