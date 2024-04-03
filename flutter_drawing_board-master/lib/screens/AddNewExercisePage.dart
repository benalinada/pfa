import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/view/RedrawnImagePage%20.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/models/drawing_mode.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/models/sketch.dart';
import 'package:flutter_drawing_board/view/drawing_page.dart';

void main() {
  runApp(AddNewExercisePage());
}
  late final ValueNotifier<Sketch?> currentSketch;
  late final ValueNotifier<DrawingMode> drawingMode;
  late final ValueNotifier<List<Sketch>> allSketches;
    late final ImageProvider imageProvider;
class AddNewExercisePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Navigation'),
        ),
        body: Row(
          children: [
            Expanded(
              flex: 1,
              child: DrawingPage(),
            ),
            
          ],
        ),
      ),
    );
  }
}
