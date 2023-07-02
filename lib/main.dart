import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project_gemastik/Admin/mainPage.dart';
import 'package:project_gemastik/discover.dart';
import 'package:project_gemastik/firebase_options.dart';
import 'package:project_gemastik/homepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Give spacer between status bar and scaffold
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    GetMaterialApp(
      /// The home property of the GetMaterialApp
      /// widget is set to a StreamBuilder widget.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final user = snapshot.data!;

            // Check if the logged-in user is an admin
            if (user.email == 'admin1@amail.com') {
              return AdminMainPage();
            } else {
              return HomePage();
            }
          } else {
            return DiscoverPage();
          }
        },
      ),

      /// Other properties of the GetMaterialApp widget
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        useMaterial3: true,
      ),
    ),
  );
}
