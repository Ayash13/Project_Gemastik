import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:project_gemastik/productPage.dart';

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FavoriteItemList(),
    );
  }
}

class FavoriteItemList extends StatefulWidget {
  const FavoriteItemList({Key? key}) : super(key: key);

  @override
  State<FavoriteItemList> createState() => _FavoriteItemListState();
}

class _FavoriteItemListState extends State<FavoriteItemList> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in, handle accordingly
      return Center(child: Text('Please log in to view your Favorites'));
    }

    final favoriteRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorite');

    return StreamBuilder<QuerySnapshot>(
      stream: favoriteRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading Favorites'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final favoriteItems = snapshot.data?.docs ?? [];

        if (favoriteItems.isEmpty) {
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
                'Favorite',
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
              child: Text('Your Favorites is empty'),
            ),
          );
        }
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
              'Favorite',
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
            itemCount: favoriteItems.length,
            itemBuilder: (context, index) {
              final favoriteItem = favoriteItems[index];
              final productId = favoriteItem['productId'] ?? '';
              final productPrice = favoriteItem['price'] ?? 0;

              final FavoriteItemTile favoriteItemTile = FavoriteItemTile(
                productId: productId,
                productPrice: productPrice,
                removeFromFavorite: () => removeFromFavorite(productId),
              );

              return favoriteItemTile;
            },
          ),
        );
      },
    );
  }

  void removeFromFavorite(String productId) {
    final favoriteItems = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
        .collection('favorite');
    final favoriteItem = favoriteItems.doc(productId);
    favoriteItem.delete();
  }
}

class FavoriteItemTile extends StatelessWidget {
  final String productId;
  final double productPrice;
  final VoidCallback removeFromFavorite;

  FavoriteItemTile({
    required this.productId,
    required this.productPrice,
    required this.removeFromFavorite,
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

        return GestureDetector(
          onTap: () {
            // Navigate to the product page when tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductPage(
                    productId:
                        productId), // Pass the product ID or other details
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.black),
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Color.fromARGB(154, 58, 57, 57),
                    offset: Offset(0, 20),
                    blurRadius: 10,
                    spreadRadius: -10)
              ],
            ),
            child: Stack(
              children: [
                Row(
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
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: Text(
                              productDescription,
                              maxLines: 3,
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
                          Text(
                            'Rp${(productPrice).toStringAsFixed(0)}',
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 189, 64, 64),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                //remove
                Positioned(
                  top: 15,
                  right: 0,
                  child: GestureDetector(
                    onTap: removeFromFavorite,
                    child: Container(
                      margin: EdgeInsets.only(right: 13),
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black),
                        borderRadius: BorderRadius.circular(30),
                        color: Color.fromARGB(203, 255, 140, 140),
                      ),
                      child: Icon(
                        MdiIcons.heart,
                        size: 20,
                        color: Color.fromARGB(205, 246, 75, 63),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
