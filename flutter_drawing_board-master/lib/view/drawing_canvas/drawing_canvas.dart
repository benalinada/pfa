import 'dart:convert';

import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_drawing_board/main.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/models/drawing_mode.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/models/sketch.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DrawingCanvas extends HookWidget {
  final double height;
  final double width;

  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<Image?> backgroundImage;
  final ValueNotifier<double> eraserSize;
  final ValueNotifier<DrawingMode> drawingMode;
  final AnimationController sideBarController;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<int> polygonSides;
  final ValueNotifier<bool> filled;


  const DrawingCanvas({
    Key? key,
    required this.height,
    required this.width,
    required this.selectedColor,
    required this.strokeSize,
    required this.eraserSize,
    required this.drawingMode,
    required this.sideBarController,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
    required this.filled,
    required this.polygonSides,
    required this.backgroundImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return MouseRegion(
      cursor: SystemMouseCursors.precise,
      child: Stack(
        children: [
          buildAllSketches(context),
          buildCurrentPath(context),
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () => sendCoordinatesToServerOnClick(context),
              child: const Text('Show'),
            ),
          ),
        ],
      ),
    );
  }

Future<void> speak(String message) async {
    FlutterTts flutterTts = FlutterTts();
  await flutterTts.setLanguage("en-US"); // Utilisation de la langue anglaise
  await flutterTts.setPitch(1.0);
  await flutterTts.setSpeechRate(1.0);
  await flutterTts.setVolume(1.0);
  await flutterTts.speak(message);
}

  void sendCoordinatesToServerOnClick(BuildContext context) {
    List<double> xCoordinates = [];
    List<double> yCoordinates = [];

    // Récupérer les coordonnées de tous les points de l'image
    for (final sketch in allSketches.value) {
      for (final point in sketch.points) {
        final x = point.dx;
        final y = point.dy;

        // Ajouter les coordonnées x et y aux tableaux respectifs
        xCoordinates.add(x);
        yCoordinates.add(y);
      }
    }
   print(xCoordinates);
    print(yCoordinates);
    // Appel de la fonction pour obtenir les directions
    // List<String> directions =
    //     getDirections(xCoordinates.cast<int>(), yCoordinates.cast<int>());


List<String> directions = detectDirection(xCoordinates.cast<int>(),yCoordinates.cast<int>());
    
       List<Map<String, dynamic>> resultat = compterMots(directions);
        List<Arrow> arrows = [];

            
      String message = '';

        List<Arrow> arrowsData = resultat.map((element) => Arrow(
          size: element['compteur'],
          direction: element['mot'],
        )).toList();


        resultat.forEach((element) {
          message += '${element['compteur']} ${element['mot']}, ';
      
        });

        arrowsData.forEach((arrow) {
  print("Size: ${arrow.size}, Direction: ${arrow.direction}");
});
      String message2 = ArrowMessageGenerator(arrowsData);
    // Afficher les directions dans un dialogue
    print(message2);
  showArrowDialog(context, arrowsData ,  message2 );
  }

static String ArrowMessageGenerator(List<Arrow> arrowsData) {
  // Suppression des flèches avec une taille inférieure à 5
  arrowsData.removeWhere((arrow) => arrow.size < 10);

  String message = 'First, ';

  for (var i = 0; i < arrowsData.length; i++) {
    var arrow = arrowsData[i];

    // Diviser la taille par 4
    int dividedSize = arrow.size ~/ 4;

    // Transformation des directions selon les spécifications
    String transformedDirection = '';
    switch (arrow.direction.toLowerCase()) {
      case 'haut':
        transformedDirection = 'forward';
        break;
      case 'bas':
        transformedDirection = 'backward';
        break;
      case 'gauche':
        transformedDirection = 'left';
        break;
      case 'droit':
        transformedDirection = 'right';
        break;
      default:
        transformedDirection = arrow.direction; // Utilise la direction d'origine si elle ne correspond pas aux cas ci-dessus
    }

    // Construction du message en fonction de la direction et de la taille
    if (i > 0) {
      if (i == arrowsData.length - 1) {
        // Ajouter "and finally" avant le dernier élément
        message += 'and finally ';
      } else {
        message += ', then ';
      }
    }
    message += 'take $dividedSize steps to the $transformedDirection';
  }

  // Ajout de la ponctuation appropriée
  message += '.';

  // Retourne le message final
  return message;
}

  void onPointerDown(PointerDownEvent details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: [offset],
        size: drawingMode.value == DrawingMode.eraser
            ? eraserSize.value
            : strokeSize.value,
        color: drawingMode.value == DrawingMode.eraser
            ? kCanvasColor
            : selectedColor.value,
        sides: polygonSides.value,
      ),
      drawingMode.value,
      filled.value,
    );
  }

  void onPointerMove(PointerMoveEvent details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    final points = List<Offset>.from(currentSketch.value?.points ?? [])
      ..add(offset);

    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: points,
        size: drawingMode.value == DrawingMode.eraser
            ? eraserSize.value
            : strokeSize.value,
        color: drawingMode.value == DrawingMode.eraser
            ? kCanvasColor
            : selectedColor.value,
        sides: polygonSides.value,
      ),
      drawingMode.value,
      filled.value,
    );
  }

  void onPointerUp(PointerUpEvent details) {
    allSketches.value = List<Sketch>.from(allSketches.value)
      ..add(currentSketch.value!);

    // Réinitialiser le dessin actuel
    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: [],
        size: drawingMode.value == DrawingMode.eraser
            ? eraserSize.value
            : strokeSize.value,
        color: drawingMode.value == DrawingMode.eraser
            ? kCanvasColor
            : selectedColor.value,
        sides: polygonSides.value,
      ),
      drawingMode.value,
      filled.value,
    );
  }

  Widget buildAllSketches(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ValueListenableBuilder<List<Sketch>>(
        valueListenable: allSketches,
        builder: (context, sketches, _) {
          return RepaintBoundary(
            key: canvasGlobalKey,
            child: Container(
              height: height,
              width: width,
              color: kCanvasColor,
              child: CustomPaint(
                painter: SketchPainter(
                  sketches: sketches,
                  backgroundImage: backgroundImage.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return Listener(
      onPointerDown: (details) => onPointerDown(details, context),
      onPointerMove: (details) => onPointerMove(details, context),
      onPointerUp: onPointerUp,
      child: ValueListenableBuilder<Sketch?>(
        valueListenable: currentSketch,
        builder: (context, sketch, child) {
          return RepaintBoundary(
            child: SizedBox(
              height: height,
              width: width,
              child: CustomPaint(
                painter: SketchPainter(
                  sketches: sketch == null
                      ? []
                      : [sketch], // Utilisez [sketch] au lieu de []
                ),
              ),
            ),
          );
        },
      ),
    );
  }

List<String> detectDirection(List<int> x, List<int> y) {
    List<String> direction = [];
    List<String> directiontest = [];
    for (int i = 0; i < x.length - 1; i++) {
      if (x[i + 1] == x[i]) {
        if (y[i + 1] < y[i]) {
          directiontest.add('Haut');
        } else if (y[i + 1] > y[i]) {
           directiontest.add('Bas');
        }
      } else if (x[i + 1] > x[i]) {
        if (y[i + 1] < y[i]) {
           directiontest.add('Haut/droit');
        } else if (y[i + 1] > y[i]) {
           directiontest.add('Bas/droit');
        }else if (y[i + 1] == y[i]) {
           directiontest.add('droit');
        }
      } else if (x[i + 1] < x[i]) {

        if (y[i + 1] < y[i]) {
           directiontest.add('Haut/Gauche');
        } else if (y[i + 1] < y[i]) {
           directiontest.add('Bas/Gauche');
        }else if (y[i + 1] == y[i]) {
           directiontest.add('Gauche');
        }

     

      }

    }

           print(directiontest);
  direction = filtrerListe(directiontest);

    return direction;
  }

List<Map<String, dynamic>> compterMots(List<String> tableau) {
  List<Map<String, dynamic>> mots = [];
  int compteur = 1;

  for (int i = 1; i < tableau.length; i++) {
    if (tableau[i] == tableau[i - 1]) {
      compteur++;
    } else {
      mots.add({'mot': tableau[i - 1], 'compteur': compteur});
      compteur = 1;
    }
  }

  mots.add({'mot': tableau.last, 'compteur': compteur});

  return mots;
}



List<String> filtrerListe(List<String> liste) {
  if (liste.length <= 2) {
    return liste;
  }

  List<String> resultat = [liste[0]];

  for (int i = 1; i < liste.length - 1; i++) {
    if (liste[i] != liste[i - 1] && liste[i] != liste[i + 1]) {
      continue;
    }
    resultat.add(liste[i]);
  }

  resultat.add(liste[liste.length - 1]);

  return resultat;
}


 
void showArrowDialog(BuildContext context, List<Arrow> arrows, String direction) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Directions'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ajouter un espace entre la description et les flèches
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: drawArrows(arrows),
            ),
            SizedBox(height: 16.0),
            Text('Directions: $direction'), // Ajouter la description ici
          ],
        ),
        actions: <Widget>[
          // Ajouter un espace entre la description et les flèches
                GestureDetector(
                  onTap: () {
                    speak(direction); // Appeler la fonction de lecture vocale
                  },
                  child: Icon(Icons.volume_up), // Icône pour la lecture vocale
                ),
                 SizedBox(width: 16.0), 
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String? selectedPatient = (await showPatientsListDialog(context ,arrows, direction)) as String?;
                    if (selectedPatient != null) {
                      print('Patient sélectionné: $selectedPatient');
                    } else {
                      print('Aucun patient sélectionné.');
                    }

              Navigator.of(context).pop(); 
            },
            child: Text('Send'),
          ),
        ],
      );
    },
  );
}

Future<List<String>?> showPatientsListDialog(BuildContext context , List<Arrow> arrows, String direction) async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('patient').get();

    List<String> patients = [];
    querySnapshot.docs.forEach((doc) {
      patients.add(doc.data()['name']);
    });

    List<String> selectedPatients = [];

    return showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text('Select patients.'),
              content: SingleChildScrollView(
                child: Column(
                  children: patients.map((String patient) {
                    bool isSelected = selectedPatients.contains(patient);
                    return CheckboxListTile(
                      title: Text(patient),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value != null) {
                            if (value) {
                              selectedPatients.add(patient);
                            } else {
                              selectedPatients.remove(patient);
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
             actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // Sauvegarder les données dans Firebase
                    saveData(arrows, direction);
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Data saved successfully'),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  } catch (e) {
    print('Error fetching patients: $e');
    return null;
  }
}
List<Widget> drawArrows(List<Arrow> arrows) {
 
  List<Widget> widgets = [];

  for (Arrow arrow in arrows) {
    switch (arrow.direction.toLowerCase()) {
      case 'haut':
        widgets.add(
          Icon(Icons.arrow_upward, size: arrow.size),
        );
        break;
      case 'bas':
        widgets.add(
          Icon(Icons.arrow_downward, size: arrow.size),
        );
        break;
      case 'gauche':
        widgets.add(
          Icon(Icons.arrow_back, size: arrow.size),
        );
        break;
      case 'droit':
        widgets.add(
          Icon(Icons.arrow_forward, size: arrow.size),
        );
        break;
      case 'haut/droit':
        widgets.add(
          Icon(Icons.arrow_forward, size: arrow.size),
        );
        widgets.add(
          Transform.rotate(
            angle: math.pi / 4,
            child: Icon(Icons.arrow_forward, size: arrow.size),
          ),
        );
        break;
      case 'haut/gauche':
        widgets.add(
          Icon(Icons.arrow_back, size: arrow.size),
        );
        widgets.add(
          Transform.rotate(
            angle: math.pi / 4,
            child: Icon(Icons.arrow_back, size: arrow.size),
          ),
        );
        break;
      case 'bas/droit':
        widgets.add(
          Icon(Icons.arrow_forward, size: arrow.size),
        );
        widgets.add(
          Transform.rotate(
            angle: math.pi / 4,
            child: Icon(Icons.arrow_forward, size: arrow.size),
          ),
        );
        break;
      case 'bas/gauche':
        widgets.add(
          Icon(Icons.arrow_back, size: arrow.size),
        );
        widgets.add(
          Transform.rotate(
            angle: math.pi / 4,
            child: Icon(Icons.arrow_back, size: arrow.size),
          ),
        );
        break;
      default:
        break;
    }
  }

  return widgets;
}

Future<void> saveData(List<Arrow> arrows, String direction ) async {
  try {
    // Initialisez une instance de Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Ajoutez les données dans la collection "arrows"
    await firestore.collection('arrows').add({
      'direction': direction,
      'arrows': arrows.map((arrow) => {
        'size': arrow.size,
        'direction': arrow.direction,
      }).toList(),
    });

    print('Data saved to Firestore successfully');
  } catch (e) {
    print('Error saving data to Firestore: $e');
  }
}

}

void showSuccessMessage(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Data saved successfully'),
      duration: Duration(seconds: 2), // Durée pendant laquelle le SnackBar est affiché
    ),
  );
}

class Arrow {
  final double size;
  final String direction;

  Arrow({required this.size, required this.direction});

  
}
class SketchPainter extends CustomPainter {
  final List<Sketch> sketches;
  final Image? backgroundImage;

  const SketchPainter({
    Key? key,
    this.backgroundImage,
    required this.sketches,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundImage != null) {
      canvas.drawImageRect(
        backgroundImage!,
        Rect.fromLTWH(
          0,
          0,
          backgroundImage!.width.toDouble(),
          backgroundImage!.height.toDouble(),
        ),
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint(),
      );
    }
    for (Sketch sketch in sketches) {
      final points = sketch.points;
      if (points.isEmpty) return;

      final path = Path();

      path.moveTo(points[0].dx, points[0].dy);
      if (points.length < 2) {
        // If the path only has one line, draw a dot.
        path.addOval(
          Rect.fromCircle(
            center: Offset(points[0].dx, points[0].dy),
            radius: 1,
          ),
        );
      }

      for (int i = 1; i < points.length - 1; ++i) {
        final p0 = points[i];
        final p1 = points[i + 1];
        path.quadraticBezierTo(
          p0.dx,
          p0.dy,
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );
      }

      Paint paint = Paint()
        ..color = sketch.color
        ..strokeCap = StrokeCap.round;

      if (!sketch.filled) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = sketch.size;
      }

      // define first and last points for convenience
      Offset firstPoint = sketch.points.first;
      Offset lastPoint = sketch.points.last;

      // create rect to use rectangle and circle
      Rect rect = Rect.fromPoints(firstPoint, lastPoint);

      // Calculate center point from the first and last points
      Offset centerPoint = (firstPoint / 2) + (lastPoint / 2);

      // Calculate path's radius from the first and last points
      double radius = (firstPoint - lastPoint).distance / 2;

      if (sketch.type == SketchType.scribble) {
        canvas.drawPath(path, paint);
      } else if (sketch.type == SketchType.square) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(5)),
          paint,
        );
      } else if (sketch.type == SketchType.line) {
        canvas.drawLine(firstPoint, lastPoint, paint);
      } else if (sketch.type == SketchType.circle) {
        canvas.drawOval(rect, paint);
        // Uncomment this line if you need a PERFECT CIRCLE
        // canvas.drawCircle(centerPoint, radius , paint);
      } else if (sketch.type == SketchType.polygon) {
        Path polygonPath = Path();
        int sides = sketch.sides;
        var angle = (math.pi * 2) / sides;

        double radian = 0.0;

        Offset startPoint =
            Offset(radius * math.cos(radian), radius * math.sin(radian));

        polygonPath.moveTo(
          startPoint.dx + centerPoint.dx,
          startPoint.dy + centerPoint.dy,
        );
        for (int i = 1; i <= sides; i++) {
          double x = radius * math.cos(radian + angle * i) + centerPoint.dx;
          double y = radius * math.sin(radian + angle * i) + centerPoint.dy;
          polygonPath.lineTo(x, y);
        }
        polygonPath.close();
        canvas.drawPath(polygonPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SketchPainter oldDelegate) {
    return oldDelegate.sketches != sketches;
  }
}
