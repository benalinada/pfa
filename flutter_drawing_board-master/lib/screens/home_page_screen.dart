import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/screens/AddNewExercisePage.dart';
import 'package:flutter_drawing_board/screens/AddNewPatientPage.dart';
import 'package:flutter_drawing_board/screens/ListExercisesPage.dart';
import 'package:flutter_drawing_board/screens/ListPatientsPage.dart';
import 'package:flutter_drawing_board/screens/PatientProgressPage.dart';
import 'package:flutter_drawing_board/theme/light_color.dart';
import 'package:flutter_drawing_board/view/drawing_page.dart';


class HomePageScreen extends StatelessWidget {
  const HomePageScreen({Key? key}) : super(key: key);

  @override
Widget build(BuildContext context) {
 return Scaffold(
    body: Stack(
      children: <Widget>[
        // Background image with doctor's face
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage( 'assets/svgs/doctor_face.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),

        // Gradient overlay with adjusted opacity for better readability
        Positioned.fill(
          child: Opacity(
            opacity: 0.4, // Adjust opacity as needed
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                 colors: [LightColor.purpleExtraLight, LightColor.purple],
                 begin: Alignment.topCenter,
                 end: Alignment.bottomCenter,
                 tileMode: TileMode.mirror,
                 stops: [.5, 6],
                ),
              ),
            ),
          ),
        ),

        // Content column with centered alignment
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Top spacer
              SizedBox(height: 50), // Adjust the height as needed

              // List of action buttons with fixed size and centered
              ElevatedButton(
                onPressed: () => Navigator.push(
                 context,
                 MaterialPageRoute(
                    builder: (context) => AddNewPatientPage(),
                 ),
                ),
                child: Text('Add New Patient'),
              style: ElevatedButton.styleFrom(
                 fixedSize: Size(200, 50), // Fixed width and height
                 alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Adjust border radius as needed
                    ),
                ),
              ),
              SizedBox(height: 20), // Spacing between buttons
              ElevatedButton(
                onPressed: () => Navigator.push(
                 context,
                 MaterialPageRoute(
                    builder: (context) => AddNewPatientPage(),
                 ),
                ),
                child: Text('View Patient List'),
                style: ElevatedButton.styleFrom(
                 fixedSize: Size(200, 50), // Fixed width and height
                 alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Adjust border radius as needed
                    ),
                ),
              ),
              SizedBox(height: 20), // Spacing between buttons
              // Spacing between buttons
               // Spacing between buttons
              ElevatedButton(
                onPressed: () => Navigator.push(
                 context,
                 MaterialPageRoute(
                    builder: (context) =>  AddNewExercisePage(),
                 ),
                ),
                child: Text('Create New Exercise'),
                style: ElevatedButton.styleFrom(
                 fixedSize: Size(200, 50), // Fixed width and height
                 alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Adjust border radius as needed
                    ),
                ),
              ),
              SizedBox(height: 20), // Spacing between buttons
              ElevatedButton(
                onPressed: () => Navigator.push(
                 context,
                 MaterialPageRoute(
                    builder: (context) =>  ListExercisesPage(),
                 ),
                ),
                child: Text('List of Exercises'),
                style: ElevatedButton.styleFrom(
                 fixedSize: Size(200, 50), // Fixed width and height
                 alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Adjust border radius as needed
                    ),
                ),
              ),     SizedBox(height: 20),
                ElevatedButton(
                onPressed: () => Navigator.push(
                 context,
                 MaterialPageRoute(
                    builder: (context) => PatientProgressPage(),
                 ),
                ),
                child: Text('Track Patient Progress'),
                style: ElevatedButton.styleFrom(
                 fixedSize: Size(200, 50), // Fixed width and height
                 alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Adjust border radius as needed
                    ),
                ),
              ),
         
              // Bottom spacer
              SizedBox(height: 50), // Adjust the height as needed
            ],
          ),
        ),
      ],
    ),
 );
}

}
