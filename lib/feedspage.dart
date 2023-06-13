import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/src/dropdown_button2.dart';
import 'package:flutter/material.dart';
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

  String selectedOption = 'Sort By';
  List<String> dropdownOptions = [
    'Sort By',
    'Plastic',
    'Paper',
    'Metal',
  ];

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
        child: Padding(
          padding:
              const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
          child: Column(
            children: [
              Container(
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
              Row(
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
                      final productChunks = chunkList(
                          products, 2); // Split products into chunks of 2

                      return ListView.builder(
                        padding: EdgeInsets.only(top: 0),
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: productChunks.length,
                        itemBuilder: (context, index) {
                          return Column(
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
                                    child: ProductContainer(
                                      productName: data['title'],
                                      description: data['description'],
                                      price: data['price'],
                                      imageUrls: imageUrls,
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 10), // Add gap between rows
                            ],
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ),
            ],
          ),
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
      width: MediaQuery.of(context).size.width,
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
              height: 180,
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
            Text(
              productName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '\Rp ${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
