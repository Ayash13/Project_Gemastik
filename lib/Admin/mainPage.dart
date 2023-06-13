import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:project_gemastik/Admin/booksPage.dart';
import 'package:project_gemastik/Admin/marketPlace.dart';
import 'package:project_gemastik/Admin/trashPickup.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({Key? key}) : super(key: key);

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int selectedIndex = 0;
  PageController _pageController = PageController(initialPage: 0);

  void onItemSelected(int index) {
    setState(() {
      selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: onItemSelected,
        children: [
          TrashPickup(),
          MarketPlace(),
          Books(),
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
                        MdiIcons.recycle,
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
                        MdiIcons.bookOpen,
                        color: selectedIndex == 2 ? Colors.black : Colors.white,
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
}

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Color.fromARGB(176, 126, 186, 148),
          border: Border.all(
            width: 1.5,
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            'Welcome Admin',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color.fromARGB(255, 20, 20, 20),
            ),
          ),
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
