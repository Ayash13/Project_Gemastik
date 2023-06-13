import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:project_gemastik/login.dart';
import 'package:project_gemastik/signup.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final PageController _pageController = PageController();
  double _currentPage = 0;
  bool _showRegisterPage = false;
  ScrollController _scrollController = ScrollController();
  double _previousScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.offset > _previousScrollOffset &&
          _showRegisterPage) {
        setState(() {
          _showRegisterPage = false;
        });
      } else if (_scrollController.offset < _previousScrollOffset &&
          !_showRegisterPage) {
        setState(() {
          _showRegisterPage = true;
        });
      }
      _previousScrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
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
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              Container(
                height: 630,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page.toDouble();
                    });
                  },
                  children: [
                    buildDiscoverSection(
                      'assets/image/hero.png',
                      'Discover 1',
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec eget augue vitae ex ultricies vehicula.',
                    ),
                    buildDiscoverSection(
                      'assets/image/hero.png',
                      'Discover 2',
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec eget augue vitae ex ultricies vehicula.',
                    ),
                    buildDiscoverSection(
                      'assets/image/hero.png',
                      'Discover 3',
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec eget augue vitae ex ultricies vehicula.',
                    ),
                  ],
                ),
              ),
              DotsIndicator(
                dotsCount: 3,
                position: _currentPage.toInt(),
                decorator: DotsDecorator(
                  color: Colors.grey,
                  activeColor: Colors.black,
                  size: const Size.square(8),
                  activeSize: const Size(16, 8),
                  spacing: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ),
              SizedBox(
                height: 35,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 248, 235),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          border: Border.all(width: 1.5, color: Colors.black),
                        ),
                        child: SignUp(),
                      ),
                    ),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color.fromARGB(220, 126, 186, 148),
                      border: Border.all(width: 1.5, color: Colors.black),
                    ),
                    child: Center(
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.rubik(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 248, 235),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          border: Border.all(width: 1.5, color: Colors.black),
                        ),
                        child: LogIn(),
                      ),
                    ),
                  ),
                  child: Container(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDiscoverSection(
      String imageAsset, String title, String description) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 390,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color.fromARGB(211, 184, 182, 251),
              border: Border.all(width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imageAsset),
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
