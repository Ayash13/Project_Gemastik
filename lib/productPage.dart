import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'cartPage.dart';
import 'checkOutScreen.dart';

class ProductPage extends StatefulWidget {
  final String productId;

  ProductPage({required this.productId});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  bool isFavorited = false;
  bool isAddedToCart = false;

  int quantity = 1;
  @override
  void initState() {
    super.initState();
    checkCartStatus();
    checkFavoriteStatus();
  }

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    setState(() {
      if (quantity > 1) {
        quantity--;
      }
    });
  }

  Future<void> checkCartStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in, handle accordingly
      return;
    }

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    final productDoc = cartRef.doc(widget.productId);
    final productSnapshot = await productDoc.get();

    setState(() {
      isAddedToCart = productSnapshot.exists;
    });
  }

  Future<void> toggleCartStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in, handle accordingly
      return;
    }

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    final productDoc = cartRef.doc(widget.productId);

    final productSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();

    if (productSnapshot.exists) {
      final productData = productSnapshot.data() as Map<String, dynamic>;
      final productPrice = productData['price'] as double;

      final productDataToAdd = {
        'productId': widget.productId,
        'quantity': quantity,
        'price': productPrice
      };

      if (isAddedToCart) {
        // Remove from cart
        await productDoc.delete();
      } else {
        // Add to cart
        await productDoc.set(productDataToAdd);
      }

      setState(() {
        isAddedToCart = !isAddedToCart;
      });
    }
  }

  Future<void> checkFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in, handle accordingly
      return;
    }

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorite');

    final productDoc = favRef.doc(widget.productId);
    final productSnapshot = await productDoc.get();

    setState(() {
      isFavorited = productSnapshot.exists;
    });
  }

  Future<void> toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in, handle accordingly
      return;
    }

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorite');

    final productDoc = favRef.doc(widget.productId);

    final productSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();

    if (productSnapshot.exists) {
      final productData = productSnapshot.data() as Map<String, dynamic>;
      final productPrice = productData['price'] as double;

      final productDataToAdd = {
        'productId': widget.productId,
        'price': productPrice
      };

      if (isFavorited) {
        await productDoc.delete();
      } else {
        await productDoc.set(productDataToAdd);
      }

      setState(() {
        isFavorited = !isFavorited;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where(FieldPath.documentId, isEqualTo: widget.productId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final products = snapshot.data!.docs;
          if (products.isNotEmpty) {
            final productData = products.first.data() as Map<String, dynamic>;
            final imageUrls = productData['images'] as List<dynamic>?;

            return Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 30,
                          left: 20,
                          right: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 2, color: Colors.black),
                                  borderRadius: BorderRadius.circular(30),
                                  color: Color.fromARGB(255, 140, 203, 255),
                                ),
                                child: Icon(MdiIcons.arrowLeft),
                              ),
                            ),
                            Text(
                              'Detail Product',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromARGB(255, 20, 20, 20),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(CartPage());
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 2, color: Colors.black),
                                  borderRadius: BorderRadius.circular(30),
                                  color: Color.fromARGB(160, 126, 186, 148),
                                ),
                                child: Icon(MdiIcons.cartOutline),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 1.5,
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          toggleFavorite();
                                        });
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2, color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: Color.fromARGB(
                                              255, 255, 226, 140),
                                        ),
                                        child: Icon(
                                          MdiIcons.heart,
                                          color: isFavorited
                                              ? Color.fromARGB(
                                                  255, 255, 105, 94)
                                              : Color.fromARGB(255, 0, 0, 0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 50,
                                ),
                                Center(
                                  child: Text(
                                    '\Rp ${productData['price'].toStringAsFixed(0)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 189, 64, 64),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Center(
                                  child: Text(
                                    productData['title'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          const Color.fromARGB(255, 20, 20, 20),
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  height: 50,
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.black),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            SizedBox(height: 10),
                                            Text(
                                              'Quantity',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: const Color.fromARGB(
                                                    255, 20, 20, 20),
                                              ),
                                            ),
                                            Text(
                                              productData['qty'].toString(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: const Color.fromARGB(
                                                    255, 20, 20, 20),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                left: BorderSide(
                                                  width: 2,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(height: 10),
                                            Text(
                                              'Category',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: const Color.fromARGB(
                                                    255, 20, 20, 20),
                                              ),
                                            ),
                                            Text(
                                              productData['category'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: const Color.fromARGB(
                                                    255, 20, 20, 20),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                left: BorderSide(
                                                  width: 2,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(height: 10),
                                            Text(
                                              'Weight',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: const Color.fromARGB(
                                                    255, 20, 20, 20),
                                              ),
                                            ),
                                            Text(
                                              '${productData['weight'].toString()} gr',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: const Color.fromARGB(
                                                    255, 20, 20, 20),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Center(
                                  child: Text(
                                    productData['description'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color:
                                          const Color.fromARGB(255, 20, 20, 20),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 120,
                    left: 65,
                    right: 65,
                    child: Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      width: 220,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          width: 1.5,
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: imageUrls != null && imageUrls.isNotEmpty
                              ? Image.network(
                                  imageUrls[0],
                                  fit: BoxFit.cover,
                                )
                              : Container(), // Placeholder if imageUrls is null or empty
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.5, color: Colors.black),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                        ),
                        color: Color.fromARGB(255, 105, 175, 233),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    decrementQuantity();
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 2, color: Colors.black),
                                      borderRadius: BorderRadius.circular(30),
                                      color: Color.fromARGB(255, 255, 226, 140),
                                    ),
                                    child: Icon(MdiIcons.minus),
                                  ),
                                ),
                                Text(
                                  quantity.toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    incrementQuantity();
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 2, color: Colors.black),
                                      borderRadius: BorderRadius.circular(30),
                                      color: Color.fromARGB(255, 255, 226, 140),
                                    ),
                                    child: Icon(MdiIcons.plus),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      toggleCartStatus();
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 2, color: Colors.black),
                                      borderRadius: BorderRadius.circular(30),
                                      color: isAddedToCart
                                          ? Color.fromARGB(255, 126, 186, 148)
                                          : Color.fromARGB(255, 255, 226, 140),
                                    ),
                                    child: Center(
                                      child: Text(
                                        isAddedToCart
                                            ? 'Remove'
                                            : 'Add to Cart',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CheckoutScreen(
                                      productId: widget.productId,
                                      quantity: quantity,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                ),
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 2, color: Colors.black),
                                  borderRadius: BorderRadius.circular(30),
                                  color: Color.fromARGB(255, 255, 140, 140),
                                ),
                                child: Center(
                                  child: Text(
                                    'Buy Now',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
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
                  )
                ],
              ),
            );
          } else {
            // Handle the case when the product with the specified ID doesn't exist
            return Scaffold(
              body: Text('Product not found'),
            );
          }
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Text('Error: ${snapshot.error}'),
          );
        } else {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
