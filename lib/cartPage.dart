import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CartItemList(),
    );
  }
}

class CartItemList extends StatefulWidget {
  @override
  _CartItemListState createState() => _CartItemListState();
}

class _CartItemListState extends State<CartItemList> {
  double totalAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in, handle accordingly
      return Center(child: Text('Please log in to view your cart'));
    }

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    return StreamBuilder<QuerySnapshot>(
      stream: cartRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading cart'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final cartItems = snapshot.data?.docs ?? [];

        if (cartItems.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leadingWidth: 75,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.only(left: 20),
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
              title: Text(
                'Cart',
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
            body: Center(
              child: Text('Your cart is empty'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 75,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                margin: EdgeInsets.only(left: 20),
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
            title: Text(
              'Cart',
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
          body: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
              final productId = cartItem['productId'] ?? '';
              final quantity = cartItem['quantity'] ?? 0;
              final productPrice = cartItem['price'] ?? 0;

              final CartItemTile cartItemTile = CartItemTile(
                productId: productId,
                quantity: quantity,
                productPrice: productPrice,
                removeFromCart: () => removeFromCart(productId),
                incrementQuantity: () => incrementQuantity(productId),
                decrementQuantity: () => decrementQuantity(productId),
              );

              totalAmount += (quantity * productPrice ?? 0.0);

              return cartItemTile;
            },
          ),
          bottomNavigationBar: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35),
              ),
              border: Border.all(width: 2, color: Colors.black),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 20, 20, 20),
                        ),
                      ),
                      Spacer(),
                      Text(
                        '\$${totalAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 20, 20, 20),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void removeFromCart(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in, handle accordingly
      return;
    }

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart');

    final productDoc = cartRef.doc(productId);
    await productDoc.delete();
  }

  void incrementQuantity(String productId) {
    setState(() {
      final cartItems = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
          .collection('cart');
      final cartItem = cartItems.doc(productId);
      cartItem.update({'quantity': FieldValue.increment(1)});
    });
  }

  void decrementQuantity(String productId) {
    final cartItems = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
        .collection('cart');
    final cartItem = cartItems.doc(productId);

    cartItem.get().then((snapshot) {
      final currentQuantity = snapshot.get('quantity') ?? 0;

      if (currentQuantity > 0) {
        cartItem.update({'quantity': FieldValue.increment(-1)});
      }
    });
  }
}

class CartItemTile extends StatelessWidget {
  final String productId;
  final int quantity;
  final double productPrice;
  final VoidCallback removeFromCart;
  final VoidCallback incrementQuantity;
  final VoidCallback decrementQuantity;

  CartItemTile({
    required this.productId,
    required this.quantity,
    required this.productPrice,
    required this.removeFromCart,
    required this.incrementQuantity,
    required this.decrementQuantity,
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
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.black),
            borderRadius: BorderRadius.circular(20),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          productName,
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        //remove
                        GestureDetector(
                          onTap: removeFromCart,
                          child: Container(
                            margin: EdgeInsets.only(right: 13),
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: Colors.black),
                              borderRadius: BorderRadius.circular(30),
                              color: Color.fromARGB(203, 255, 140, 140),
                            ),
                            child: Icon(
                              MdiIcons.trashCanOutline,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
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
                    SizedBox(
                      height: 15,
                    ),
                    // Qty counter
                    Row(
                      children: [
                        GestureDetector(
                          onTap: decrementQuantity,
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: Colors.black),
                              borderRadius: BorderRadius.circular(30),
                              color: Color.fromARGB(255, 255, 226, 140),
                            ),
                            child: Icon(MdiIcons.minus),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          quantity.toString(),
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: incrementQuantity,
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: Colors.black),
                              borderRadius: BorderRadius.circular(30),
                              color: Color.fromARGB(255, 255, 226, 140),
                            ),
                            child: Icon(MdiIcons.plus),
                          ),
                        ),
                        //price
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Text(
                            'Rp${(productPrice * quantity).toStringAsFixed(0)}',
                            style: GoogleFonts.roboto(
                              fontSize: 15,
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
