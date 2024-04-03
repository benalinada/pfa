import 'package:flutter/material.dart';
import 'light_color.dart'; // Assurez-vous que ce fichier existe et contient les couleurs définies

class AppTheme {
 const AppTheme();

 static ThemeData lightTheme = ThemeData(
    backgroundColor: LightColor.background,
    primaryColor: LightColor.purple,
    cardTheme: CardTheme(color: LightColor.background),
    textTheme: TextTheme(
      headline1: TextStyle(color: LightColor.black), // Utilisez headline1 au lieu de display1
      bodyText1: TextStyle(color: LightColor.titleTextColor), // Utilisez bodyText1 pour le texte principal
    ),
    iconTheme: IconThemeData(color: LightColor.iconColor),
    bottomAppBarColor: LightColor.background,
    dividerColor: LightColor.grey,
    primaryTextTheme: TextTheme(
      bodyText1: TextStyle(color: LightColor.titleTextColor), // Utilisez bodyText1 pour le texte principal
    ),
 );

 static TextStyle titleStyle = const TextStyle(color: LightColor.titleTextColor, fontSize: 16);
 static TextStyle subTitleStyle = const TextStyle(color: LightColor.subTitleTextColor, fontSize: 12);

 static TextStyle h1Style = const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
 static TextStyle h2Style = const TextStyle(fontSize: 22);
 static TextStyle h3Style = const TextStyle(fontSize: 20);
 static TextStyle h4Style = const TextStyle(fontSize: 18);
 static TextStyle h5Style = const TextStyle(fontSize: 16);
 static TextStyle h6Style = const TextStyle(fontSize: 14);

 static List<BoxShadow> shadow = <BoxShadow>[
    BoxShadow(color: Color(0xfff8f8f8), blurRadius: 10, spreadRadius: 15),
 ];

 static EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
 static EdgeInsets hPadding = const EdgeInsets.symmetric(horizontal: 10);

 static double fullWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
 }

 static double fullHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
 }
}
