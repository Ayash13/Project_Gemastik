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
  String? phoneNumber;
  String? userName = FirebaseAuth.instance.currentUser?.displayName ?? "";
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

  Future<void> updatePhoneNumber(String newPhoneNumber) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Save the phone number in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'phone': newPhoneNumber}, SetOptions(merge: true));

        Get.snackbar(
          'Success',
          'Phone number updated',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color.fromARGB(240, 126, 186, 148),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(10),
          borderRadius: 10,
          borderColor: Colors.black,
          borderWidth: 1.5,
        );
        setState(() {});
      } catch (error) {
        Get.snackbar(
          'Failed',
          'Failed to update phone number: $error',
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
            side: BorderSide(width: 1.5, color: Colors.black),
          ),
          backgroundColor: Color.fromARGB(255, 255, 251, 235),
          title: Center(
            child: Text(
              'Add Phone Number',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 20, 20, 20),
              ),
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
                  setState(() {
                    phoneNumber;
                  });
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

  void _showDialogPhoneUpdate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _phoneNumberController = TextEditingController();

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
            side: BorderSide(width: 1.5, color: Colors.black),
          ),
          backgroundColor: Color.fromARGB(255, 255, 251, 235),
          title: Center(
            child: Text(
              'Update Phone Number',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 20, 20, 20),
              ),
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
                  await updatePhoneNumber(_phoneNumberController.text);
                  this.phoneNumber = _phoneNumberController
                      .text; // Update the phoneNumber variable immediately
                  Navigator.of(context).pop();
                  setState(() {
                    phoneNumber;
                  });
                },
                child: const Text(
                  'Update',
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
                    setState(() {
                      addressTitle;
                    });
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

  //update displayname dialog
  void _showDialogUpdateUsername() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _usernameController = TextEditingController();

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
            side: BorderSide(width: 1.5, color: Colors.black),
          ),
          backgroundColor: Color.fromARGB(255, 255, 251, 235),
          title: Center(
            child: Text(
              'Update Username',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 20, 20, 20),
              ),
            ),
          ),
          content: TextField(
            controller: _usernameController,
            decoration: const InputDecoration(hintText: 'Username'),
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
                  FirebaseAuth.instance.currentUser
                      ?.updateDisplayName(_usernameController.text);
                  this.userName = _usernameController
                      .text; // Update the phoneNumber variable immediately
                  Navigator.of(context).pop();
                  setState(() {
                    userName;
                  });
                },
                child: const Text(
                  'Update',
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
                      setState(() {
                        userAddresses;
                      });
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
                    'Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 20, 20, 20),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: Colors.black,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(108, 178, 178, 178),
                    offset: Offset(0, 10),
                    blurRadius: 7,
                    spreadRadius: 2,
                  ),
                ],
                color: Color.fromARGB(155, 255, 219, 153),
              ),
              child: FractionallySizedBox(
                widthFactor: 0.50,
                heightFactor: 0.85,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 1.5,
                      color: Colors.black,
                    ),
                    color: Colors.white,
                  ),
                  child: FirebaseAuth.instance.currentUser?.photoURL != null
                      ? CircleAvatar(
                          radius: 0.375 * 300,
                          backgroundImage: NetworkImage(
                              FirebaseAuth.instance.currentUser!.photoURL!),
                        )
                      : Icon(
                          Icons.person_rounded,
                          size: 100,
                          color: Colors.black,
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Stack(
              children: [
                Positioned(
                  right: 10,
                  top: 3,
                  child: GestureDetector(
                    onTap: () {
                      _showDialogUpdateUsername();
                    },
                    child: Icon(
                      MdiIcons.accountEdit,
                      size: 20,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      userName!,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 20, 20, 20),
                      ),
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ?? "",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 20, 20, 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
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
                        height: 20,
                      ),
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<
                                    DocumentSnapshot<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          // Check if the document exists and contains the 'Point' field
                          if (snapshot.hasData &&
                              snapshot.data!.exists &&
                              snapshot.data!.data()!.containsKey('Point')) {
                            double pointValueDouble =
                                snapshot.data!.data()!['Point'];
                            int pointValue = pointValueDouble.toInt();

                            return Column(
                              children: [
                                Text(
                                  pointValue.toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 60,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        const Color.fromARGB(255, 20, 20, 20),
                                  ),
                                ),
                              ],
                            );
                          }

                          // Handle the case when the document doesn't exist or doesn't contain the 'Point' field
                          return Center(
                            child: Text('Point not found'),
                          );
                        },
                      ),
                      SizedBox(
                        height: 15,
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
                          child: Center(
                            child: Text(
                              'Your Point',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromARGB(255, 20, 20, 20),
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
            SizedBox(
              height: 20,
            ),
            Container(
              height: 195,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.black),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                ),
                color: Color.fromARGB(155, 255, 232, 188),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (phoneNumber != null) {
                          _showDialogPhoneUpdate();
                        } else {
                          _showDialogAddPhone();
                        }
                      },
                      child: Container(
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
                                  MdiIcons.phone,
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
                                    'Phone Number',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          const Color.fromARGB(255, 20, 20, 20),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    phoneNumber != null
                                        ? '$phoneNumber'
                                        : 'Please add phone number',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color:
                                          const Color.fromARGB(255, 20, 20, 20),
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
                                child: Icon(
                                  phoneNumber != null
                                      ? Icons.arrow_forward_ios_rounded
                                      : Icons.add,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
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
                                Icons.home,
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
                                  'Address',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        const Color.fromARGB(255, 20, 20, 20),
                                  ),
                                ),
                                SizedBox(height: 5),
                                userAddresses != null &&
                                        userAddresses!.isNotEmpty
                                    ? Text(
                                        userAddresses!.values.first?['title'] ??
                                            'Please add address',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: const Color.fromARGB(
                                              255, 20, 20, 20),
                                        ),
                                      )
                                    : Text(
                                        'Please add address',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: const Color.fromARGB(
                                              255, 20, 20, 20),
                                        ),
                                      )
                              ],
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                _showDialogAddAddress();
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1.5,
                                    color: Colors.black,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            GestureDetector(
                              onTap: () {
                                showAddress();
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1.5,
                                    color: Colors.black,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
