import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_gemastik/cartPage.dart';

class CheckoutScreen extends StatefulWidget {
  final String productId;
  late final int quantity;

  CheckoutScreen({
    required this.productId,
    required this.quantity,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final List<Map<String, dynamic>> cartItems = Get.arguments ?? [];
  int _quantity = 1;
  double totalAmount = 0.0;
  Map<String, dynamic>? userAddresses;
  String? phoneNumber;
  @override
  void initState() {
    super.initState();
    fetchAddresses();
    fetchPhoneNumber();
    _quantity = widget.quantity;
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
          totalAmount += (_quantity * productPrice);

          return Padding(
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
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 3, right: 3),
                      height: 160,
                      child: ProductItemTile(
                        productId: widget.productId,
                        quantity: _quantity,
                        productPrice: productPrice,
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
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.37,
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
                                        'Email :',
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
                                        FirebaseAuth
                                                .instance.currentUser?.email ??
                                            '',
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
                                      top: 10, bottom: 10, left: 30, right: 30),
                                  child: Center(
                                    child: Text(
                                      'Rp${(totalAmount.toStringAsFixed(0))}',
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
                    SizedBox(
                      height: 3,
                    ),
                    //confirm
                    Container(
                      margin: EdgeInsets.only(left: 3, right: 3),
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
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductItemTile extends StatelessWidget {
  final String productId;
  final int quantity;
  final double productPrice;

  ProductItemTile({
    required this.productId,
    required this.quantity,
    required this.productPrice,
  });

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
            top: 20,
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
                    SizedBox(height: 10),
                    Text(
                      productName,
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
