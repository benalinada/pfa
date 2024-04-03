import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/screens/home_page_screen.dart';
import 'package:flutter_drawing_board/theme/extention.dart';
import 'package:flutter_drawing_board/theme/light_color.dart';
import 'package:flutter_drawing_board/theme/text_styles.dart';


class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashScreen> {
  @override


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage( 'assets/svgs/doctor_face.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: .6,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [LightColor.purpleExtraLight, LightColor.purple],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      tileMode: TileMode.mirror,
                      stops: [.5, 6]),
                ),
              ),
            ),
          ),
         Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: SizedBox(),
                  ),
                  Image.asset(
                    'assets/svgs/heartbeat.png',
                    color: Colors.white,
                    height: 100,
                  ),
                  Text(
                    'Time Health',
                    style: TextStyles.h1Style.white,
                  ),
                  Text(
                    'By healthcare Evolution',
                    style: TextStyles.bodySm.white.bold,
                  ),
                      Expanded(
                    flex:1,
                    child: SizedBox(),
                  ),
                  Expanded(
                      flex: 1, // Ajustez la flexibilité selon votre besoin
                      child: Center( // Centrer le bouton
                        child: Container(
                          width: 200, // Largeur personnalisée du bouton
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => HomePageScreen()),
                              );
                            },
                            child: Text('Start'),
                                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(200, 50), // Fixed width and height
                        alignment: Alignment.center,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0), // Adjust border radius as needed
                            ),
                ),
                          ),
                        ),
                      ),
                    ),

                  Expanded(
                    flex: 7,
                    child: SizedBox(),
                  ),
                ],
              ).alignTopCenter,

        ],
      ),
    );
  }
}
