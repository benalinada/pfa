import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/model/doctor_model.dart';
import 'package:flutter_drawing_board/screens/detail_screen.dart';
import 'package:flutter_drawing_board/screens/home_page_screen.dart';
import 'package:flutter_drawing_board/screens/splash_screen.dart';
import 'package:flutter_drawing_board/widgets/custom_route_widget.dart';


class Routes {
static Map<String, WidgetBuilder> getRoute() {
 return <String, WidgetBuilder>{
    '/': (_) => SplashScreen(key: ValueKey('SplashScreen')),
    '/HomePage': (_) => HomePageScreen(key: ValueKey('HomePageScreen')),
 };
}
 static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
final List<String> pathElements = settings.name?.split('/') ?? [];



    if (pathElements[0] != '' || pathElements.length == 1) {
      return null;
    }
   switch (pathElements[1]) {
      case "DetailPage":
        if (settings.arguments is DoctorModel) {
         return CustomRoute(
 builder: (BuildContext context) => DetailScreen(
    model: settings.arguments as DoctorModel,
 ),
);

        }
        break;
    }
    return null;
 }
}
