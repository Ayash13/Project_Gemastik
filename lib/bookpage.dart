import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BookPage extends StatefulWidget {
  const BookPage({Key? key}) : super(key: key);

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 239, 239),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                top: 30,
                bottom: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 50),
                    child: Text(
                      "DIY Recycle-able Trash",
                      style: GoogleFonts.poppins(
                        fontSize: 37,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 42, 41, 41),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Search bar
                  Container(
                    margin: EdgeInsets.only(right: 20),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 237, 202),
                      border: Border.all(
                        width: 1.5,
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        const Icon(Icons.search),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {}); // Rebuild the widget tree
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  StatefulBuilder(
                    builder: (context, setState) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('contents')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final List<DocumentSnapshot> documents =
                              snapshot.data!.docs;

                          // Apply search filter
                          final filteredDocuments = documents.where((document) {
                            final title = document['title'] ?? '';
                            return title
                                .toLowerCase()
                                .contains(_searchController.text.toLowerCase());
                          }).toList();

                          if (filteredDocuments.isEmpty) {
                            return Text('No data available');
                          }

                          final int maxItemCount = 4;
                          final List<DocumentSnapshot> initialData =
                              filteredDocuments.take(maxItemCount).toList();
                          final List<DocumentSnapshot> remainingData =
                              filteredDocuments.skip(maxItemCount).toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  'New Content',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 42, 41, 41),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Stack(
                                children: [
                                  Positioned(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        left: 20,
                                      ),
                                      height: 350,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1.5,
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                        ),
                                        color:
                                            Color.fromARGB(255, 254, 188, 188),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 35, bottom: 15, top: 15),
                                    child: SizedBox(
                                      height: 320,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: initialData.map((document) {
                                            final title =
                                                document['title'] ?? '';
                                            final coverImageUrl =
                                                document['coverImageUrl'] ?? '';
                                            final htmlContent =
                                                document['content'];
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ContentPage(
                                                      title: title,
                                                      coverImageUrl:
                                                          coverImageUrl,
                                                      htmlContent: htmlContent,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: 200,
                                                height: 320,
                                                margin:
                                                    EdgeInsets.only(right: 15),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    width: 2,
                                                    color: Color.fromARGB(
                                                        255, 89, 88, 88),
                                                  ),
                                                  color: Colors.white,
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15, right: 15),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const SizedBox(height: 5),
                                                      Container(
                                                        clipBehavior: Clip
                                                            .antiAliasWithSaveLayer,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        child: Image.network(
                                                          coverImageUrl,
                                                          width: 180,
                                                          height: 230,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Text(
                                                        title,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "More DIY",
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 42, 41, 41),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 15,
                                        mainAxisSpacing: 15,
                                        childAspectRatio: 0.65,
                                      ),
                                      itemCount: remainingData.length,
                                      itemBuilder: (context, index) {
                                        final document = remainingData[index];
                                        final title = document['title'] ?? '';
                                        final coverImageUrl =
                                            document['coverImageUrl'] ?? '';
                                        final htmlContent = document['content'];

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ContentPage(
                                                  title: title,
                                                  coverImageUrl: coverImageUrl,
                                                  htmlContent: htmlContent,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                width: 2,
                                                color: Color.fromARGB(
                                                    255, 89, 88, 88),
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 150,
                                                    height: 195,
                                                    clipBehavior: Clip
                                                        .antiAliasWithSaveLayer,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    child: Image.network(
                                                      coverImageUrl,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 15),
                                                  Text(
                                                    title,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContentPage extends StatelessWidget {
  final String title;
  final String coverImageUrl;
  final String htmlContent;

  const ContentPage({
    Key? key,
    required this.title,
    required this.coverImageUrl,
    required this.htmlContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Color.fromARGB(193, 255, 248, 235),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 30,
                left: 20,
                right: 20,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
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
                  Text(
                    'Book',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 20, 20, 20),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      margin: EdgeInsets.only(top: 150),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(149, 62, 57, 49),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Card(
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: Image.network(
                              height: 260,
                              width: 200,
                              coverImageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              child: Html(
                                data: htmlContent,
                                style: {
                                  "html": Style(
                                    fontSize: FontSize(20),
                                    color: Colors.white,
                                    textAlign: TextAlign.center,
                                  ),
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
