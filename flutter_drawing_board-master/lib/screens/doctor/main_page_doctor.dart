import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/screen/AddNewExercisePage.dart';
import 'package:flutter_drawing_board/screen/PatientProgressPage.dart';
import 'package:flutter_drawing_board/screens/patient/doctor_list.dart';
import 'package:flutter_drawing_board/screens/patient/home_page.dart';
import 'package:flutter_drawing_board/view/drawing_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_drawing_board/screens/chat/chats.dart';
import 'package:flutter_drawing_board/screens/my_profile.dart';
import 'package:flutter_drawing_board/screens/patient/appointments.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

class MainPageDoctor extends StatefulWidget {
  const MainPageDoctor({Key? key}) : super(key: key);

  @override
  State<MainPageDoctor> createState() => _MainPageDoctorState();
}

class _MainPageDoctorState extends State<MainPageDoctor> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 2;
  final List<Widget> _pages = [
   
    const Appointments(),
       HomePage(),
    AddNewExercisePage(),
    PatientProgressPage(),
    const MyProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: _scaffoldKey,
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
              child: GNav(
                curve: Curves.easeOutExpo,
                rippleColor: Colors.grey.shade300,
                hoverColor: Colors.grey.shade100,
                haptic: true,
                tabBorderRadius: 20,
                gap: 5,
                activeColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: const Duration(milliseconds: 200),
                tabBackgroundColor: Colors.blue.withOpacity(0.7),
                textStyle: GoogleFonts.lato(
                  color: Colors.white,
                ),
                iconSize: 30,
                tabs: const [
                  GButton(
                    icon: Typicons.th_list,
                    text: 'List of exercices',
                  ),
                  GButton(
                    icon: Typicons.th_list,
                    text: 'list Paitent',
                  ), GButton(
                    icon: Icons.add /* Typicons.group_outline */,
                    text: 'Add',
                  ),
                  GButton(
                    icon: Typicons.chart_area,
                    text: 'Dashbord',
                  ),
                 
                  GButton(
                    icon: Typicons.user,
                    text: 'Profile',
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: _onItemTapped,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
