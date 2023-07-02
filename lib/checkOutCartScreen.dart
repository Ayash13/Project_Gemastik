import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:slide_to_act/slide_to_act.dart';

import 'package:project_gemastik/confirmPayment.dart';
import 'package:project_gemastik/notification.dart';
import 'package:project_gemastik/profilepage.dart';

class CheckoutCartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  CheckoutCartScreen({
    super.key,
    required this.cartItems,
  });

  @override
  _CheckoutCartScreenState createState() => _CheckoutCartScreenState();
}

class _CheckoutCartScreenState extends State<CheckoutCartScreen> {
  int quantity = 1;
  double totalAmount = 0.0;
  Map<String, dynamic>? userAddresses;
  String? phoneNumber;
  //false = trasfer bank
  //true = credit card
  bool isPaymentMethod = false;
  @override
  void initState() {
    super.initState();
    fetchAddresses();
    fetchPhoneNumber();
    calculateTotalAmount();
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

  void showAddress() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 251, 255, 252),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          border: Border.all(width: 1.5, color: Colors.black),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Your Address',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: userAddresses!.length,
                itemBuilder: (BuildContext context, int index) {
                  final addressKeys = userAddresses!.keys.toList();
                  final address = userAddresses!.values.toList()[index];
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Dismissible(
                      key: Key(addressKeys[
                          index]), // Use the address key as the dismissible key
                      onDismissed: (direction) {
                        setState(() {
                          // Remove the address from the userAddresses map and Firestore
                          deleteUserAddress(address);
                          userAddresses!.remove(addressKeys[
                              index]); // Update the userAddresses map
                        });
                      },
                      background: Container(
                        // Container for the background when swiping
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.5,
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          color: Color.fromARGB(147, 255, 90, 90),
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Icon(
                              MdiIcons.delete,
                              size: 30,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      child: Container(
                        //cobtainer 1
                        decoration: BoxDecoration(
                          border: Border.all(width: 1.5, color: Colors.black),
                          borderRadius: BorderRadius.circular(20),
                          color: Color.fromARGB(150, 126, 186, 148),
                        ),
                        child: ListTile(
                          title: Text(
                            address['title'],
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${address['province']}, ${address['city']}, ${address['roadNumber']}',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //delete users adrresess in spesific address
  Future<void> deleteUserAddress(Map<String, dynamic> address) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CollectionReference addressesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses');

      await addressesRef
          .where('title', isEqualTo: address['title'])
          .where('province', isEqualTo: address['province'])
          .where('city', isEqualTo: address['city'])
          .where('roadNumber', isEqualTo: address['roadNumber'])
          .get()
          .then((snapshot) {
        snapshot.docs.first.reference.delete();
      });
    }
  }

  void calculateTotalAmount() {
    final cartItems = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
        .collection('cart');

    cartItems.get().then((snapshot) {
      double calculatedTotalAmount = 0.0;
      for (var doc in snapshot.docs) {
        final quantity = doc.data()?['quantity'] ?? 0;
        final productPrice = doc.data()?['price'] ?? 0.0;
        calculatedTotalAmount += (quantity * productPrice);
      }
      setState(() {
        totalAmount = calculatedTotalAmount;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: Stack(
        children: [
          Positioned(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.black),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  color: Color.fromARGB(255, 255, 240, 212),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.only(top: 20),
                height: MediaQuery.of(context).size.height * 0.4,
                child: ListView.builder(
                  itemCount: widget.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = widget.cartItems[index];
                    final productId = cartItem['productId'] ?? '';
                    final quantity = cartItem['quantity'] ?? 0;
                    final productPrice = cartItem['price'] ?? 0.0;

                    // Retrieve product details from Firestore based on the productId
                    final productRef = FirebaseFirestore.instance
                        .collection('products')
                        .doc(productId);

                    return FutureBuilder<DocumentSnapshot>(
                      future: productRef.get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final productData =
                              snapshot.data!.data() as Map<String, dynamic>? ??
                                  {};
                          final productName =
                              productData['title'] as String? ?? '';
                          final productImages =
                              productData['images'] as List<dynamic>? ?? [];
                          final productDescription =
                              productData['description'] as String? ?? '';

                          // Select the first image URL from the list (you can adjust this logic based on your requirements)
                          final productImageURL = productImages.isNotEmpty
                              ? productImages[0] as String
                              : '';

                          return ProductItemTile(
                            productId: productId,
                            quantity: quantity,
                            productPrice: productPrice,
                            image: productImageURL,
                          );
                        }

                        if (snapshot.hasError) {
                          return Text('Error retrieving product');
                        }

                        return Center(child: CircularProgressIndicator());
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.47,
                child: Column(
                  children: [
                    Row(
                      children: List.generate(
                        155 ~/ 5,
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
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.all(20),
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
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              //order summary
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 20, right: 20),
                                child: Column(
                                  children: [
                                    Center(
                                      child: Text(
                                        'Customers Data',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: const Color.fromARGB(
                                              255, 20, 20, 20),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    //email
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Name :',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(
                                                255, 20, 20, 20),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          FirebaseAuth.instance.currentUser
                                                  ?.displayName ??
                                              "",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            color: const Color.fromARGB(
                                                255, 20, 20, 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                    //phone
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Phone :',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(
                                                255, 20, 20, 20),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '${phoneNumber}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            color: const Color.fromARGB(
                                                255, 20, 20, 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                    //address
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Address :',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(
                                                255, 20, 20, 20),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        if (userAddresses != null &&
                                            userAddresses!.isNotEmpty)
                                          GestureDetector(
                                            onTap: () {
                                              showAddress();
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 1.5,
                                                  color: Colors.black,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '${userAddresses!.values.first['title']}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color.fromARGB(
                                                      255, 20, 20, 20),
                                                ),
                                              ),
                                            ),
                                          )
                                        else
                                          GestureDetector(
                                            onTap: () {
                                              Get.off(ProfilePage());
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 1.5,
                                                  color: Colors.black,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                'Set your address first',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color.fromARGB(
                                                      255, 20, 20, 20),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: List.generate(
                                  155 ~/ 5,
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
                              Expanded(
                                child: Container(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  color: Color.fromARGB(255, 140, 203, 255),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                        left: 30,
                                        right: 30),
                                    child: Center(
                                      child: Text(
                                        '\Rp ${totalAmount.toStringAsFixed(0)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w600,
                                          color: const Color.fromARGB(
                                              255, 20, 20, 20),
                                        ),
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
                    //confirm
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => comfirmCheckout(context),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: 20,
                          left: 23,
                          right: 23,
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.black),
                          borderRadius: BorderRadius.circular(15),
                          color: Color.fromARGB(255, 140, 203, 255),
                        ),
                        child: Center(
                          child: Text(
                            'Confirm',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromARGB(255, 20, 20, 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget comfirmCheckout(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, setState) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: 570,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 235, 246, 255),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              border: Border.all(width: 2, color: Colors.black),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                    ],
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 7, right: 7),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Product :',
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          const Color.fromARGB(255, 20, 20, 20),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: List.generate(
                                  160 ~/ 2,
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
                              SizedBox(
                                height: 10,
                              ),
                              // Implementing the cart items here
                              SizedBox(
                                height: 100,
                                child: ListView(
                                  children: [
                                    Column(
                                      children: List.generate(
                                        widget.cartItems.length,
                                        (index) {
                                          final cartItem =
                                              widget.cartItems[index];
                                          final productId =
                                              cartItem['productId'] ?? '';
                                          final quantity =
                                              cartItem['quantity'] ?? 0;
                                          final productPrice =
                                              cartItem['price'] ?? 0.0;

                                          // Retrieve product details from Firestore based on the productId
                                          final productRef = FirebaseFirestore
                                              .instance
                                              .collection('products')
                                              .doc(productId);

                                          return FutureBuilder<
                                              DocumentSnapshot>(
                                            future: productRef.get(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                final productData =
                                                    snapshot.data!.data()
                                                            as Map<String,
                                                                dynamic>? ??
                                                        {};
                                                final productName =
                                                    productData['title']
                                                            as String? ??
                                                        '';

                                                return Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '${productName} :',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: const Color
                                                                  .fromARGB(
                                                              255, 20, 20, 20),
                                                        ),
                                                      ),
                                                      Text(
                                                        'Rp ${(productPrice * quantity).toStringAsFixed(0)}',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: const Color
                                                                  .fromARGB(
                                                              255, 20, 20, 20),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }

                                              if (snapshot.hasError) {
                                                return Text(
                                                    'Error retrieving product');
                                              }

                                              return Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: List.generate(
                                  160 ~/ 2,
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
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Shipping price :',
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          const Color.fromARGB(255, 20, 20, 20),
                                    ),
                                  ),
                                  Text(
                                    'Rp 0',
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          const Color.fromARGB(255, 20, 20, 20),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total price :',
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          const Color.fromARGB(255, 20, 20, 20),
                                    ),
                                  ),
                                  Text(
                                    'Rp ${totalAmount.toStringAsFixed(0)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          const Color.fromARGB(255, 20, 20, 20),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                        // Payment method
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1.5,
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    color: Color.fromARGB(179, 252, 119, 42),
                                  ),
                                  child: Icon(
                                    MdiIcons.creditCard,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  height: 40,
                                  width: 2,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Transfer Bank',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: const Color.fromARGB(
                                            255, 20, 20, 20),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'BCA (8421184747)',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: const Color.fromARGB(
                                            255, 20, 20, 20),
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1.5,
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Radio<bool>(
                                    activeColor: Colors.black,
                                    value: isPaymentMethod,
                                    groupValue: false,
                                    onChanged: (value) {
                                      setState(() {
                                        isPaymentMethod = !isPaymentMethod;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: StreamBuilder<
                                DocumentSnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<
                                          DocumentSnapshot<
                                              Map<String, dynamic>>>
                                      snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }

                                // Check if the document exists and contains the 'Point' field
                                if (snapshot.hasData &&
                                    snapshot.data!.exists &&
                                    snapshot.data!
                                        .data()!
                                        .containsKey('Point')) {
                                  double pointValueDouble =
                                      snapshot.data!.data()!['Point'];
                                  int pointValue = pointValueDouble.toInt();

                                  return Row(
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1.5,
                                            color: Colors.black,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color:
                                              Color.fromARGB(179, 252, 119, 42),
                                        ),
                                        child: Icon(
                                          MdiIcons.star,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Container(
                                        height: 40,
                                        width: 2,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Point',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: const Color.fromARGB(
                                                  255, 20, 20, 20),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            pointValue.toString(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: const Color.fromARGB(
                                                  255, 20, 20, 20),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1.5,
                                            color: Colors.black,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Builder(
                                            builder: (BuildContext context) {
                                          if (pointValue >= totalAmount) {
                                            return Radio<bool>(
                                              activeColor: Colors.black,
                                              value: isPaymentMethod,
                                              groupValue: true,
                                              onChanged: (value) {
                                                setState(() {
                                                  isPaymentMethod =
                                                      !isPaymentMethod;
                                                });
                                              },
                                            );
                                          } else {
                                            return GestureDetector(
                                              onTap: () {
                                                Get.snackbar(
                                                  'Error',
                                                  'Not enough point',
                                                  snackPosition:
                                                      SnackPosition.TOP,
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          244, 249, 135, 127),
                                                  colorText: Colors.white,
                                                  duration:
                                                      Duration(seconds: 1),
                                                  margin: EdgeInsets.all(10),
                                                  borderRadius: 10,
                                                  borderColor: Colors.black,
                                                  borderWidth: 1.5,
                                                );
                                              },
                                              child: Tooltip(
                                                message: 'Insufficient Points',
                                                child: Opacity(
                                                  opacity: 0,
                                                  child: Radio<bool>(
                                                    activeColor: Colors.black,
                                                    value: isPaymentMethod,
                                                    groupValue: false,
                                                    onChanged: null,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }),
                                      ),
                                      SizedBox(width: 15),
                                    ],
                                  );
                                }

                                // Handle the case when the document doesn't exist or doesn't contain the 'Point' field
                                return Center(child: Text('Point not found'));
                              },
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 20,
                        ),
                        SlideAction(
                          sliderButtonIcon: Icon(
                            MdiIcons.arrowRight,
                            color: Colors.black,
                          ),
                          sliderButtonIconSize: 40,
                          elevation: 0,
                          borderRadius: 20,
                          innerColor: Colors.white,
                          outerColor: Color.fromARGB(220, 126, 186, 148),
                          onSubmit: () async {
                            try {
                              final User? currentUser =
                                  FirebaseAuth.instance.currentUser;
                              if (currentUser == null) {
                                return; // User is not signed in, handle accordingly
                              }

                              final userRef = FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUser.uid);
                              final transactionData = {
                                'address': userAddresses,
                                'name': FirebaseAuth
                                        .instance.currentUser?.displayName ??
                                    '',
                                'email':
                                    FirebaseAuth.instance.currentUser?.email ??
                                        '',
                                'phone': phoneNumber,
                                'time': DateTime.now(),
                                'date': DateTime.now().day,
                                'month': DateTime.now().month,
                                'products': widget.cartItems,
                                'shippingPrice': 0,
                                'totalPrice': totalAmount,
                                'paymentMethod':
                                    isPaymentMethod ? 'Point' : 'Transfer Bank',
                                'status': isPaymentMethod
                                    ? 'Payment success'
                                    : 'Waiting for payment',
                              };

                              if (isPaymentMethod) {
                                final userSnapshot = await userRef.get();
                                final int pointValue =
                                    userSnapshot.data()?['Point'] ?? 0;
                                if (pointValue >= totalAmount) {
                                  await userRef.update(
                                      {'Point': pointValue - totalAmount});
                                } else {
                                  // Show an error message or handle insufficient points accordingly
                                  return;
                                }
                              }

                              final transactionRef =
                                  userRef.collection('transactions').doc();
                              final transactionId = transactionRef.id;
                              transactionData['id'] = transactionId;

                              await transactionRef.set(transactionData);

                              final transactionHistory = TransactionHistory(
                                id: transactionId,
                                address: userAddresses as List<dynamic>,
                                name: FirebaseAuth
                                        .instance.currentUser?.displayName ??
                                    '',
                                email:
                                    FirebaseAuth.instance.currentUser?.email ??
                                        '',
                                phone: phoneNumber as String,
                                time: DateTime.now(),
                                date: DateTime.now().day,
                                month: DateTime.now().month,
                                products: widget.cartItems,
                                shippingPrice: 0,
                                totalPrice: totalAmount,
                                paymentMethod:
                                    isPaymentMethod ? 'Point' : 'Transfer Bank',
                                status: isPaymentMethod
                                    ? 'Payment success'
                                    : 'Waiting for payment',
                              );

                              // Save the transaction history to Firestore
                              await transactionRef
                                  .set(transactionHistory.toMap());

                              Get.back(); // Show a success message or navigate to another screen
                            } catch (error) {
                              print('Error saving transaction: $error');
                              // Show an error message or handle the error accordingly
                            }
                            Get.offAll(ConfirmPayment());
                          },
                          sliderButtonIconPadding: 16,
                          child: Container(
                            margin: EdgeInsets.only(left: 30),
                            child: Text(
                              'Slide to confirm',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromARGB(255, 20, 20, 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProductItemTile extends StatelessWidget {
  final String productId;
  final int quantity;
  final String image;
  final double productPrice;

  ProductItemTile({
    Key? key,
    required this.productId,
    required this.quantity,
    required this.image,
    required this.productPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsRef = FirebaseFirestore.instance.collection('products');

    return FutureBuilder<DocumentSnapshot>(
      future: productsRef.doc(productId).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ListTile(
            title: Text('Error loading product'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final productData = snapshot.data?.data() as Map<String, dynamic>?;
        final productName = productData?['title'] ?? 'Product';
        final productDescription = productData?['description'] ?? '';
        final productImages = productData?['images'] ?? [];
        final productImage = productImages.isNotEmpty ? productImages[0] : '';
        final productPrice = productData?['price'] ?? 0.0;

        return Container(
          margin: EdgeInsets.only(
            left: 40,
            right: 40,
            top: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.black),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(width: 1.5, color: Colors.black),
                  image: DecorationImage(
                    image: NetworkImage(productImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
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
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Text(
                        productDescription,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1.5,
                      color: Colors.black,
                      endIndent: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'x ${quantity.toString()}',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Text(
                            '${(productPrice * quantity).toStringAsFixed(0)}',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 189, 64, 64),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
