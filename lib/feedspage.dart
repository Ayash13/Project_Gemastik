import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/src/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:project_gemastik/homepage.dart';

class FeedsPage extends StatefulWidget {
  const FeedsPage({Key? key}) : super(key: key);

  @override
  State<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
  itemAppBar appBarInstance = itemAppBar(
    iconbarColor: Color.fromARGB(160, 126, 186, 148),
    iconbar: Icon(
      MdiIcons.cartOutline,
      color: Colors.black,
    ),
  );
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  String selectedOption = 'All Product';
  List<String> dropdownOptions = [
    'All Product',
    'Plastic',
    'Paper',
    'Metal',
  ];
  List<DocumentSnapshot> sortProducts(
      List<DocumentSnapshot> products, String sortOption) {
    if (sortOption == 'All Product') {
      return List.from(products);
    } else if (sortOption == 'Plastic') {
      return products.where((doc) => doc['category'] == 'Plastic').toList();
    } else if (sortOption == 'Paper') {
      return products.where((doc) => doc['category'] == 'Paper').toList();
    } else if (sortOption == 'Metal') {
      return products.where((doc) => doc['category'] == 'Metal').toList();
    }

    return List.from(products);
  }

  List<DocumentSnapshot>? sortedProducts;
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Color.fromARGB(193, 255, 248, 235),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 30, left: 20, right: 20),
              height: 60,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color.fromARGB(130, 255, 255, 255),
                border: Border.all(
                  width: 1.5,
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 251, 231, 194),
                        border: Border.all(
                          width: 1.5,
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      //searchbar
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              height: 1.3,
                            ),
                            border: InputBorder.none,
                            suffixIcon: Icon(MdiIcons.magnify),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  //cart
                  appBarInstance,
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Find recycle things',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.5, color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromARGB(255, 251, 231, 194),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: dropDown(),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final products = snapshot.data!.docs;

                    // Filter products based on search query
                    final filteredProducts = products.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final productName =
                          data['title'].toString().toLowerCase();
                      return productName.contains(searchQuery.toLowerCase());
                    }).toList();

                    sortedProducts =
                        sortProducts(filteredProducts, selectedOption);
                    final productChunks = chunkList(sortedProducts!, 2.1);
                    // Use sorted products

                    return ListView.builder(
                      padding: EdgeInsets.only(top: 0),
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: productChunks.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: productChunks[index].map((document) {
                                  final data =
                                      document.data() as Map<String, dynamic>;
                                  final List<dynamic> imageUrls =
                                      document['images'] ?? [];

                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 5,
                                        right: 5,
                                      ),
                                      child: ProductContainer(
                                        productName: data['title'],
                                        description: data['description'],
                                        price: data['price'],
                                        imageUrls: imageUrls,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 10), // Add gap between rows
                            ],
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  DropdownButton2<String> dropDown() {
    return DropdownButton2<String>(
      value: selectedOption,
      underline: Container(),
      dropdownStyleData: DropdownStyleData(
        elevation: 0,
        isOverButton: true,
        width: 150,
        decoration: BoxDecoration(
          border: Border.all(width: 1.5, color: Colors.black),
          borderRadius: BorderRadius.circular(10),
          color: Color.fromARGB(255, 251, 231, 194),
        ),
      ),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedOption = newValue;
          });
        }
      },
      items: dropdownOptions.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(
            option,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ProductContainer extends StatelessWidget {
  final String productName;
  final String description;
  final double price;
  final List<dynamic> imageUrls;

  ProductContainer({
    Key? key,
    required this.productName,
    required this.description,
    required this.price,
    required this.imageUrls,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 194, 225, 251),
        border: Border.all(
          width: 1.5,
          color: Colors.black,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 1.5,
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrls[0],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                productName,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromARGB(255, 20, 20, 20),
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: const Color.fromARGB(255, 20, 20, 20),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                '\Rp ${price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// Helper function to chunk a list into smaller lists
List<List<T>> chunkList<T>(List<T> list, double chunkSize) {
  List<List<T>> chunks = [];
  var currentIndex = 0;
  while (currentIndex < list.length) {
    var endIndex = (currentIndex + chunkSize).toInt();
    endIndex = endIndex.clamp(0, list.length);
    chunks.add(list.sublist(currentIndex, endIndex));
    currentIndex = endIndex;
  }
  return chunks;
}
