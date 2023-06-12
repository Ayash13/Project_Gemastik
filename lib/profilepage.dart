import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isBack = true;
  double angle = 0;

  void _flip() {
    setState(() {
      angle = (angle + pi) % (2 * pi);
    });
  }

  String? phoneNumber;
  String? userId;
  Map<String, dynamic>? userAddresses;

  @override
  void initState() {
    super.initState();
    // Call the method to retrieve the user data when the widget initializes
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    await fetchPhoneNumber();
    await fetchAddresses();
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

  Future<void> addPhoneNumber(String phoneNumber) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Save the phone number in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'phone': phoneNumber}, SetOptions(merge: true));

        Get.snackbar(
          'Success',
          'Phone number added',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color.fromARGB(240, 126, 186, 148),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(10),
          borderRadius: 10,
          borderColor: Colors.black,
          borderWidth: 1.5,
        );
      } catch (error) {
        Get.snackbar(
          'Failed',
          'Failed to add phone number: $error',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color.fromARGB(244, 249, 135, 127),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(10),
          borderRadius: 10,
          borderColor: Colors.black,
          borderWidth: 1.5,
        );
      }
    }
  }

  bool isAdress = false;
  bool isPhoneNumber = false;

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

  void _showDialogAddPhone() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _phoneNumberController = TextEditingController();

        return AlertDialog(
          title: Text(
            'Add Phone Number',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 20, 20, 20),
            ),
          ),
          content: TextField(
            controller: _phoneNumberController,
            decoration: const InputDecoration(hintText: 'Phone Number'),
            keyboardType: TextInputType.phone,
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(193, 225, 156, 156),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(150, 126, 186, 148),
              ),
              child: TextButton(
                onPressed: () async {
                  await addPhoneNumber(_phoneNumberController.text);
                  this.phoneNumber = _phoneNumberController
                      .text; // Update the phoneNumber variable immediately
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDialogAddAddress() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String addressTitle = '';
        String province = '';
        String city = '';
        String roadNumber = '';

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
            side: BorderSide(width: 1.5, color: Colors.black),
          ),
          backgroundColor: Color.fromARGB(255, 255, 251, 235),
          title: Center(
            child: Text(
              'Add Address',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    addressTitle = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter address title',
                ),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    province = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter province',
                ),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    city = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter city',
                ),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    roadNumber = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter road/house number',
                ),
              ),
            ],
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(193, 225, 156, 156),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(150, 126, 186, 148),
              ),
              child: TextButton(
                onPressed: () {
                  if (addressTitle.isNotEmpty &&
                      province.isNotEmpty &&
                      city.isNotEmpty &&
                      roadNumber.isNotEmpty) {
                    saveAddress(addressTitle, province, city, roadNumber);
                    Navigator.of(context).pop();
                    Get.snackbar(
                      'Success',
                      'New address added',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Color.fromARGB(240, 126, 186, 148),
                      colorText: Colors.white,
                      duration: Duration(seconds: 3),
                      margin: EdgeInsets.all(10),
                      borderRadius: 10,
                      borderColor: Colors.black,
                      borderWidth: 1.5,
                    );
                  } else {
                    // Show an error message or perform any desired action
                    // snackbar
                    Get.snackbar(
                      'Error',
                      'Please fill in all the fields.',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Color.fromARGB(244, 212, 115, 108),
                      colorText: Colors.white,
                      duration: Duration(seconds: 3),
                      margin: EdgeInsets.all(10),
                      borderRadius: 10,
                      borderColor: Colors.black,
                      borderWidth: 1.5,
                    );
                  }
                },
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveAddress(String addressTitle, String province, String city,
      String roadNumber) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CollectionReference addressesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses');

      await addressesRef.add({
        'title': addressTitle,
        'province': province,
        'city': city,
        'roadNumber': roadNumber,
      });
      await fetchAddresses();
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
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(212, 206, 205, 241),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1.5,
                      color: Colors.black,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      MdiIcons.arrowLeft,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 1.5,
                  color: Colors.black,
                ),
                color: Color.fromARGB(155, 255, 219, 153),
              ),
              child: FractionallySizedBox(
                widthFactor: 0.85,
                heightFactor: 0.85,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 1.5,
                      color: Colors.black,
                    ),
                    color: Colors.transparent,
                  ),
                  child: CircleAvatar(
                    radius: 0.375 *
                        300, // Adjust this value to set the radius based on the height of the inner container
                    backgroundImage: NetworkImage(
                        FirebaseAuth.instance.currentUser?.photoURL ?? ""),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(
                    right: 20,
                    left: 20,
                    top: 20,
                  ),
                  child: GestureDetector(
                    onTap: _flip,
                    child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: angle),
                        duration: Duration(seconds: 1),
                        builder: (BuildContext context, double val, __) {
                          //here we will change the isBack val so we can change the content of the card
                          if (val >= (pi / 2)) {
                            isBack = false;
                          } else {
                            isBack = true;
                          }
                          return (Transform(
                            //let's make the card flip by it's center
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(val),
                            child: isBack
                                ? profileCard(
                                    context) //if it's back we will display here
                                : Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..rotateY(
                                          pi), // it will flip horizontally the container
                                    child: designCard(context)),
                          ));
                        }),
                  )),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: userAddresses != null && userAddresses!.isNotEmpty
                    //call the title
                    ? GestureDetector(
                        onTap: () {
                          showAddress();
                        },
                        child: Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    userAddresses!.values.first['title'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          const Color.fromARGB(255, 20, 20, 20),
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Text(
                            'There is no address yet',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromARGB(255, 20, 20, 20),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
              ),
              GestureDetector(
                onTap: () {
                  _showDialogAddAddress();
                },
                child: Container(
                  height: 60,
                  width: 140,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(150, 126, 186, 148),
                    border: Border.all(
                      width: 1.5,
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(
                          MdiIcons.plus,
                          size: 30,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Add address',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color.fromARGB(255, 20, 20, 20),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container profileCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          width: 2,
          color: Colors.black,
        ),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FirebaseAuth.instance.currentUser?.displayName ?? "",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? "",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (phoneNumber != null)
                  Text(
                    '$phoneNumber',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _showDialogAddPhone,
                    child: Container(
                      margin: EdgeInsets.only(top: 15),
                      width: 160,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(212, 206, 205, 241),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 1.5,
                          color: Colors.black,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Add Phone Number",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    // line
                    width: MediaQuery.of(context).size.width,
                    height: 5,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.5, color: Colors.black),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    //child container
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(155, 255, 219, 153),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 1.5,
                          color: Colors.black,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Your Point :',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(212, 206, 205, 241),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      width: 1.5,
                                      color: Colors.black,
                                    ),
                                  ),
                                  child: Icon(MdiIcons.crown),
                                ),
                                Text(
                                  '0',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color.fromARGB(210, 224, 188, 188),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 1.5,
                    color: Colors.black,
                  ),
                ),
                child: Icon(MdiIcons.closeCircleOutline),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container designCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            width: 2,
            color: Colors.black,
          ),
          color: Color.fromARGB(255, 194, 225, 251)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Column(
              children: [
                Center(
                  child: Text(
                    'Your Design',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 20, 20, 20),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color.fromARGB(210, 224, 188, 188),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 1.5,
                    color: Colors.black,
                  ),
                ),
                child: Icon(MdiIcons.closeCircleOutline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
