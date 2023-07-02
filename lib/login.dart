import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:project_gemastik/Admin/mainPage.dart';
import 'package:project_gemastik/homepage.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();
  // Initialize the FirebaseAuth and GoogleSignIn instances.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  late String email;
  late String password;

  bool _isPasswordVisible = false;

  //SignIn with email and password
  Future<void> _logInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      final User? user = userCredential.user;
      if (user != null) {
        Get.snackbar(
          'Success',
          'Success to LogIn with email and password',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color.fromARGB(240, 126, 186, 148),
          colorText: Colors.black,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(10),
          borderRadius: 10,
          borderColor: Colors.black,
          borderWidth: 1.5,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Get.snackbar(
          'Error',
          'No user found for that email',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color.fromARGB(244, 249, 135, 127),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(10),
          borderRadius: 10,
          borderColor: Colors.black,
          borderWidth: 1.5,
        );
      } else if (e.code == 'wrong-password') {
        Get.snackbar(
          'Error',
          'Wrong password provided for that user',
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

  Future<void> _logInAdmin(String email, String password) async {
    try {
      // Sign in with email and password using Firebase Authentication
      final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user is an admin based on their email
      final user = authResult.user;
      if (user != null && user.email == 'admin1@amail.com') {
        // Navigate to the admin page
        Get.offAll(AdminMainPage());
        Get.snackbar(
          'Success',
          'Welcome Admin!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Color.fromARGB(240, 126, 186, 148),
          colorText: Colors.black,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(10),
          borderRadius: 10,
          borderColor: Colors.black,
          borderWidth: 1.5,
        );
      } else {
        // Invalid credentials, show error message or perform other actions
        Get.snackbar(
          'Error',
          'Wrong email or password',
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
    } catch (e) {
      // Handle login errors
      Get.snackbar(
        'Error',
        '$e',
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

  //LogIn with google
  Future<void> _LogInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User? user = authResult.user;
    if (user != null) {
      Get.offAll(HomePage());
      Get.snackbar(
        'Success',
        'Success to LogIn with google',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color.fromARGB(240, 126, 186, 148),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(10),
        borderRadius: 10,
        borderColor: Colors.black,
        borderWidth: 1.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Form(
          key: _formKey,
          child: Column(
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
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Text(
                  "Log In",
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 20, 20, 20),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: "Email",
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 20, 20, 20),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          email = value;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: "Password",
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 20, 20, 20),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            child: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          password = value;
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (email == 'admin1@amail.com' &&
                            password == 'admin123') {
                          // Admin login logic
                          await _logInAdmin(email, password);
                        } else if (_formKey.currentState!.validate()) {
                          // Regular user login logic
                          await _logInWithEmailAndPassword(email, password);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color.fromARGB(255, 255, 219, 153),
                          border: Border.all(width: 1.5, color: Colors.black),
                        ),
                        child: Center(
                          child: Text(
                            'Log In',
                            style: GoogleFonts.rubik(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Or",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 20, 20, 20),
                      ),
                    ),
                    //LogIn with google
                    GestureDetector(
                      onTap: () {
                        _LogInWithGoogle();
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color.fromARGB(211, 184, 182, 251),
                          border: Border.all(width: 1.5, color: Colors.black),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                              ),
                              child: CircleAvatar(
                                child: Icon(MdiIcons.google),
                                backgroundColor: Colors.white,
                                radius: 15,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Center(
                              child: Text(
                                'Log In with Google',
                                style: GoogleFonts.rubik(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
