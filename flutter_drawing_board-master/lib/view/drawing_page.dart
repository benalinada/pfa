import 'dart:ui';
import 'package:status_alert/status_alert.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_drawing_board/main.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/drawing_canvas.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/models/drawing_mode.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/models/sketch.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/widgets/canvas_side_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DrawingPage extends HookWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedColor = useState(Colors.black);
    final strokeSize = useState<double>(10);
    final eraserSize = useState<double>(30);
    final drawingMode = useState(DrawingMode.pencil);
    final filled = useState<bool>(false);
    final polygonSides = useState<int>(3);
    final backgroundImage = useState<Image?>(null);

    final canvasGlobalKey = GlobalKey();

    ValueNotifier<Sketch?> currentSketch = useState(null);
    ValueNotifier<List<Sketch>> allSketches = useState([]);

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
    );

    // Méthode pour afficher l'alerte
    void showAlert() {
      StatusAlert.show(
        context,
        duration: Duration(seconds: 2),
        title: 'Title',
        subtitle: 'Subtitle',
        configuration: IconConfiguration(icon: Icons.done),
        maxWidth: 260,
      );
    }

    useEffect(() {
      showAlert(); // Afficher l'alerte lorsque le widget est construit
      return null;
    }, []);

    return Scaffold(
      body: Stack(
        children: [
          // Drawing space
          Positioned.fill(
            child: Container(
              color: kCanvasColor,
              child: Stack(
                children: [
                  // Dessin
                  DrawingCanvas(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    drawingMode: drawingMode,
                    selectedColor: selectedColor,
                    strokeSize: strokeSize,
                    eraserSize: eraserSize,
                    sideBarController: animationController,
                    currentSketch: currentSketch,
                    allSketches: allSketches,
                    canvasGlobalKey: canvasGlobalKey,
                    filled: filled,
                    polygonSides: polygonSides,
                    backgroundImage: backgroundImage,
                  ),
                  // Barre d'outils sur le dessin
                  Positioned(
                    top: kToolbarHeight + 10,
                    left: 10,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-1, 0),
                        end: Offset.zero,
                      ).animate(animationController),
                      child: CanvasSideBar(
                        drawingMode: drawingMode,
                        selectedColor: selectedColor,
                        strokeSize: strokeSize,
                        eraserSize: eraserSize,
                        currentSketch: currentSketch,
                        allSketches: allSketches,
                        canvasGlobalKey: canvasGlobalKey,
                        filled: filled,
                        polygonSides: polygonSides,
                        backgroundImage: backgroundImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Custom AppBar
          Positioned(
            top: 10,
            left: 10,
            child: _CustomAppBar(
              animationController: animationController,
              showAlert: showAlert,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final AnimationController animationController;
  final VoidCallback showAlert;

  const _CustomAppBar({
    Key? key,
    required this.animationController,
    required this.showAlert,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ElevatedButton(
          onPressed: showAlert,
          child: Text('Show Alert'),
        ),
      ),
    );
  }
}
