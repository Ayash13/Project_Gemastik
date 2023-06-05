import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_gemastik/discover.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:project_gemastik/favoritepage.dart';
import 'package:project_gemastik/feedspage.dart';
import 'package:project_gemastik/profilepage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  PageController _pageController = PageController(initialPage: 0);

  void onItemSelected(int index) {
    setState(() {
      selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(const DiscoverPage());
    Get.snackbar(
      'Success',
      'LogOut Success',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: onItemSelected,
        children: [
          homePageLayout(context),
          FeedsPage(),
          favoritePage(),
        ],
      ),
      bottomNavigationBar: Container(
        color: selectedIndex == 0
            ? Color.fromARGB(212, 206, 205, 241)
            : selectedIndex == 1
                ? Color.fromARGB(193, 255, 248, 235)
                : selectedIndex == 2
                    ? Color.fromARGB(210, 241, 205, 205)
                    : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 15,
          ),
          child: Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Color.fromARGB(220, 126, 186, 148),
              border: Border.all(
                width: 1.5,
                color: Colors.black,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => onItemSelected(0),
                  child: Container(
                    width: 70,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selectedIndex == 0
                          ? Color.fromARGB(255, 251, 231, 194)
                          : Colors.transparent,
                      border: Border.all(
                        width: selectedIndex == 0 ? 1.5 : 0,
                        color: selectedIndex == 0
                            ? Colors.black
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        MdiIcons.home,
                        color: selectedIndex == 0 ? Colors.black : Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => onItemSelected(1),
                  child: Container(
                    width: 70,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selectedIndex == 1
                          ? Color.fromARGB(255, 251, 231, 194)
                          : Colors.transparent,
                      border: Border.all(
                        width: selectedIndex == 1 ? 1.5 : 0,
                        color: selectedIndex == 1
                            ? Colors.black
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        MdiIcons.hanger,
                        color: selectedIndex == 1 ? Colors.black : Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => onItemSelected(2),
                  child: Container(
                    width: 70,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selectedIndex == 2
                          ? Color.fromARGB(255, 251, 231, 194)
                          : Colors.transparent,
                      border: Border.all(
                        width: selectedIndex == 2 ? 1.5 : 0,
                        color: selectedIndex == 2
                            ? Colors.black
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        MdiIcons.heart,
                        color: selectedIndex == 2
                            ? Color.fromARGB(255, 225, 103, 94)
                            : Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container homePageLayout(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Color.fromARGB(212, 206, 205, 241),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
                  //menu
                  GestureDetector(
                    onTap: () {
                      Get.to(
                        ProfilePage(),
                        transition: Transition.leftToRight,
                        duration: Duration(milliseconds: 300),
                      );
                    },
                    child: itemAppBar(
                      iconbarColor: Color.fromARGB(160, 255, 219, 153),
                      iconbar: Icon(
                        Icons.person_2_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  //add content
                  itemAppBar(
                    iconbarColor: Color.fromARGB(160, 126, 186, 148),
                    iconbar: Icon(
                      Icons.add_circle_outline,
                      color: Colors.black,
                    ),
                  ),
                  //logut
                  GestureDetector(
                    onTap: () {
                      _logout();
                    },
                    child: itemAppBar(
                      iconbarColor: Color.fromARGB(160, 249, 135, 127),
                      iconbar: Icon(
                        Icons.logout_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Text(
              'Hi, ${FirebaseAuth.instance.currentUser?.displayName ?? ""}',
              style: GoogleFonts.poppins(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 20, 20, 20),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Expanded(
              child: Container(
                //container 1
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    width: 1.5,
                    color: Colors.black,
                  ),
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class itemAppBar extends StatelessWidget {
  const itemAppBar(
      {Key? key, required this.iconbar, required this.iconbarColor})
      : super(key: key);

  final Widget iconbar;
  final Color iconbarColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 40,
      decoration: BoxDecoration(
        color: iconbarColor,
        border: Border.all(
          width: 1.5,
          color: Colors.black,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: iconbar),
    );
  }
}
