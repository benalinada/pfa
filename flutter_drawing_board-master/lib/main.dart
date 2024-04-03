import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/config/route.dart';
import 'package:flutter_drawing_board/theme/theme.dart';


void main() {
  runApp(const MyApp());
}

const Color kCanvasColor = Color.fromARGB(255, 239, 240, 242);


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
   Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false,
      title: 'Health Care App',
      theme: AppTheme.lightTheme,
      routes: Routes.getRoute(),
        onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
     
    );
  }

}
