import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatefulWidget {
  final String productId;
  final int quantity;

  CheckoutScreen({
    required this.productId,
    required this.quantity,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Map<String, dynamic>? userAddresses;
  @override
  void initState() {
    super.initState();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final addressesSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .get();

        setState(() {
          userAddresses = {};
        });

        addressesSnapshot.docs.forEach((doc) {
          final addressData = doc.data();
          if (addressData.containsKey('title')) {
            setState(() {
              userAddresses![doc.id] = addressData;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 75,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.only(left: 20),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.black),
              borderRadius: BorderRadius.circular(30),
              color: Color.fromARGB(255, 140, 203, 255),
            ),
            child: Icon(MdiIcons.arrowLeft),
          ),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 20, 20, 20),
          ),
        ),
        centerTitle: true,
        actions: [
          SizedBox(width: 40),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading product'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final productData = snapshot.data?.data() as Map<String, dynamic>?;
          final productName = productData?['title'] ?? 'Product';
          final productDescription = productData?['description'] ?? '';
          final productImages = productData?['images'] ?? [];
          final productImage = productImages.isNotEmpty ? productImages[0] : '';
          final productPrice = productData?['price'] ?? 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.all(20),
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(width: 1.5, color: Colors.black),
                  image: DecorationImage(
                    image: NetworkImage(productImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      productDescription,
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Price: Rp ${productPrice.toStringAsFixed(0)}',
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Quantity: ${widget.quantity}'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (userAddresses != null && userAddresses!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.5, color: Colors.black),
                              borderRadius: BorderRadius.circular(20),
                              color: Color.fromARGB(150, 126, 186, 148),
                            ),
                            child: ListTile(
                              title: Text(
                                userAddresses!.values.first['title'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${userAddresses!.values.first['province']}, ${userAddresses!.values.first['city']}, ${userAddresses!.values.first['roadNumber']}',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {
                    // Add code here to handle the checkout process
                  },
                  child: Text('Proceed to Checkout'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
