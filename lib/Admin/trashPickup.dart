import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:project_gemastik/Admin/mainPage.dart';
import 'package:project_gemastik/Admin/transaction.dart';
import 'package:url_launcher/url_launcher.dart';

class TrashPickup extends StatefulWidget {
  const TrashPickup({Key? key}) : super(key: key);

  @override
  State<TrashPickup> createState() => _TrashPickupState();
}

class _TrashPickupState extends State<TrashPickup> {
  void launchWhatsApp(String phone, String message) async {
    // Mengganti awalan nomor telepon jika dimulai dengan 0813 menjadi +62813
    if (phone.startsWith('0')) {
      phone = '+62' + phone.substring(1);
    }

    final formattedPhone = phone.substring(1);
    final formattedMessage = Uri.encodeComponent(message);
    final url =
        'https://api.whatsapp.com/send?phone=$formattedPhone&text=$formattedMessage&type=phone_number&app_absent=0';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Color.fromARGB(212, 206, 205, 241),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
        child: Column(
          children: [
            Row(
              children: [
                WelcomeWidget(),
                SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(TransactionPage());
                  },
                  child: itemAppBar(
                    iconbarColor: Color.fromARGB(160, 126, 186, 148),
                    iconbar: Icon(
                      MdiIcons.receiptClockOutline,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('dataSampah')
                  .orderBy('tanggal', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('Tidak ada data sampah.'),
                  );
                }

                return Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;

                        DateTime tanggal = data['tanggal'].toDate();

                        return Container(
                          margin: EdgeInsets.only(bottom: 20),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1.5,
                              color: Colors.black,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                width: 1.5,
                                                color: Colors.black,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                data['nama'],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                width: 1.5,
                                                color: Colors.black,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                data['nomorTelepon'],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
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
                                    Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          width: 1.5,
                                          color: Colors.black,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          data['alamat'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
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
                                        Expanded(
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                width: 1.5,
                                                color: Colors.black,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                data['jenisSampah'],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                width: 1.5,
                                                color: Colors.black,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${data['berat']}Kg',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
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
                                    Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          width: 1.5,
                                          color: Colors.black,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${tanggal.day}-${tanggal.month}-${tanggal.year}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        //go to whatsapp
                                        launchWhatsApp(
                                          data['nomorTelepon'],
                                          'Halo kak, kami dari Trashify ingin mengkonfirmasi penjemputan sampah atas nama ${data['nama']} pada tanggal ${tanggal.day}-${tanggal.month}-${tanggal.year} dengan berat ${data['berat']}Kg dan jenis sampah ${data['jenisSampah']}. Terima kasih.',
                                        );
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 140, 203, 255),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            width: 1.5,
                                            color: Colors.black,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Konfirmasi',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    // Delete data from Firebase
                                    String documentId =
                                        data['id']; // Access the document ID
                                    setState(() {
                                      FirebaseFirestore.instance
                                          .collection('dataSampah')
                                          .doc(documentId)
                                          .delete();
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 233, 184, 184),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        width: 1.5,
                                        color: Colors.black,
                                      ),
                                    ),
                                    child: Icon(
                                      MdiIcons.closeCircleOutline,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
