import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_drawing_board/main.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/models/drawing_mode.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/models/sketch.dart';
import 'package:flutter_drawing_board/view/drawing_canvas/widgets/color_palette.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

class CanvasSideBar extends HookWidget {
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<double> eraserSize;
  final ValueNotifier<DrawingMode> drawingMode;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<bool> filled;
  final ValueNotifier<int> polygonSides;
  final ValueNotifier<ui.Image?> backgroundImage;

  const CanvasSideBar({
    Key? key,
    required this.selectedColor,
    required this.strokeSize,
    required this.eraserSize,
    required this.drawingMode,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
    required this.filled,
    required this.polygonSides,
    required this.backgroundImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final undoRedoStack = useState(
      _UndoRedoStack(
        sketchesNotifier: allSketches,
        currentSketchNotifier: currentSketch,
      ),
    );
    final scrollController = useScrollController();
    return Container(
      width: 50,
      height: MediaQuery.of(context).size.height < 680 ? 450 : 610,
      decoration: BoxDecoration(
        color: ui.Color.fromARGB(255, 240, 239, 239),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 3,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        child: ListView(
          padding: const EdgeInsets.all(10.0),
          controller: scrollController,
          children: [
            const SizedBox(height: 10),
           
            const Divider(),
           Wrap(
    alignment: WrapAlignment.start,
    spacing: 5,
    runSpacing: 5,
    children: [
      IconButton(
        icon: Icon(
          Icons.edit,
          color: drawingMode.value == DrawingMode.pencil ? Colors.grey[900] : Colors.grey,
        ),
        onPressed: () => drawingMode.value = DrawingMode.pencil,
        tooltip: 'Pencil',
      ),
      IconButton(
        icon: Icon(
          Icons.segment,
          color: drawingMode.value == DrawingMode.line ? Colors.grey[900] : Colors.grey,
        ),
        onPressed: () => drawingMode.value = DrawingMode.line,
        tooltip: 'Line',
      ),
  
    ],
            ),
            const SizedBox(height: 8),
        
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: drawingMode.value == DrawingMode.polygon
                  ? Row(
                      children: [
                        const Text(
                          'Polygon Sides: ',
                          style: TextStyle(fontSize: 12),
                        ),
                        Slider(
                          value: polygonSides.value.toDouble(),
                          min: 3,
                          max: 8,
                          onChanged: (val) {
                            polygonSides.value = val.toInt();
                          },
                          label: '${polygonSides.value}',
                          divisions: 5,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

          
            const SizedBox(height: 20),
           
      
            const Divider(),
            Wrap(
              children: [
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.undo,
                    color: allSketches.value.isNotEmpty ? Colors.grey[900] : Colors.grey,
                  ),
                  onPressed: allSketches.value.isNotEmpty ? undoRedoStack.value.undo : null,
                  tooltip: 'Undo',
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.redo,
                    color: undoRedoStack.value._canRedo.value ? Colors.grey[900] : Colors.grey,
                  ),
                  onPressed: undoRedoStack.value._canRedo.value ? undoRedoStack.value.redo : null,
                  tooltip: 'Redo',
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.trash,
                    color: ui.Color.fromARGB(255, 131, 8, 8),
                  ),
                  onPressed: () => undoRedoStack.value.clear(),
                  tooltip: 'Clear',
                ),
              
              
             
              ],



            

              
            ),
            const Divider(),
            Wrap(
              children: [
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.save,
                    color: allSketches.value.isNotEmpty ? Colors.grey[900] : Colors.grey,
                  ),
                    onPressed: () async {
                    final bytes = await getBytes();
                    if (bytes != null) {
                      saveFile(bytes, 'png'); // Save as PNG by default

                      // Enregistrez l'image dans Firebase Storage
                      await uploadImageToFirebaseStorage(bytes, 'image.png');
                    }
                  },
                  tooltip: 'save',
                ),])

         
          ],
        ),
      ),
    );
  }

Future<void> saveFile(Uint8List bytes, String extension) async {
  if (kIsWeb) {
    print("Le téléchargement direct vers Firebase Storage n'est pas pris en charge sur le web.");
    return;
  }

  try {
    // Récupérer une référence au bucket Firebase Storage
    final ref = firebase_storage.FirebaseStorage.instance.ref().child('images').child('image_$extension');

    // Télécharger l'image vers Firebase Storage
    await ref.putData(bytes);

    print('Image téléchargée avec succès sur Firebase Storage.');
  } catch (error) {
    print('Erreur lors du téléchargement de l\'image sur Firebase Storage: $error');
  }
}

  Future<ui.Image> get _getImage async {
    final completer = Completer<ui.Image>();
    if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
      final file = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (file != null) {
        final filePath = file.files.single.path;
        final bytes = filePath == null
            ? file.files.first.bytes
            : File(filePath).readAsBytesSync();
        if (bytes != null) {
          completer.complete(decodeImageFromList(bytes));
        } else {
          completer.completeError('No image selected');
        }
      }
    } else {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        completer.complete(
          decodeImageFromList(bytes),
        );
      } else {
        completer.completeError('No image selected');
      }
    }

    return completer.future;
  }

  Future<void> _launchUrl(String url) async {
    if (kIsWeb) {
      html.window.open(
        url,
        url,
      );
    } else {
      if (!await launchUrl(Uri.parse(url))) {
        throw 'Could not launch $url';
      }
    }
  }

  Future<Uint8List?> getBytes() async {
    RenderRepaintBoundary boundary = canvasGlobalKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }
}

class _IconBox extends StatelessWidget {
  final IconData? iconData;
  final Widget? child;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;

  const _IconBox({
    Key? key,
    this.iconData,
    this.child,
    this.tooltip,
    required this.selected,
    required this.onTap,
  })  : assert(child != null || iconData != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? Colors.grey[900]! : Colors.grey,
              width: 1.5,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Tooltip(
            message: tooltip,
            preferBelow: false,
            child: child ??
                Icon(
                  iconData,
                  color: selected ? Colors.grey[900] : Colors.grey,
                  size: 20,
                ),
          ),
        ),
      ),
    );
  }
}

///A data structure for undoing and redoing sketches.
class _UndoRedoStack {
  _UndoRedoStack({
    required this.sketchesNotifier,
    required this.currentSketchNotifier,
  }) {
    _sketchCount = sketchesNotifier.value.length;
    sketchesNotifier.addListener(_sketchesCountListener);
  }

  final ValueNotifier<List<Sketch>> sketchesNotifier;
  final ValueNotifier<Sketch?> currentSketchNotifier;

  ///Collection of sketches that can be redone.
  late final List<Sketch> _redoStack = [];

  ///Whether redo operation is possible.
  ValueNotifier<bool> get canRedo => _canRedo;
  late final ValueNotifier<bool> _canRedo = ValueNotifier(false);

  late int _sketchCount;

  void _sketchesCountListener() {
    if (sketchesNotifier.value.length > _sketchCount) {
      //if a new sketch is drawn,
      //history is invalidated so clear redo stack
      _redoStack.clear();
      _canRedo.value = false;
      _sketchCount = sketchesNotifier.value.length;
    }
  }

  void clear() {
    _sketchCount = 0;
    sketchesNotifier.value = [];
    _canRedo.value = false;
    currentSketchNotifier.value = null;
  }

  void undo() {
    final sketches = List<Sketch>.from(sketchesNotifier.value);
    if (sketches.isNotEmpty) {
      _sketchCount--;
      _redoStack.add(sketches.removeLast());
      sketchesNotifier.value = sketches;
      _canRedo.value = true;
      currentSketchNotifier.value = null;
    }
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final sketch = _redoStack.removeLast();
    _canRedo.value = _redoStack.isNotEmpty;
    _sketchCount++;
    sketchesNotifier.value = [...sketchesNotifier.value, sketch];
  }

  void dispose() {
    sketchesNotifier.removeListener(_sketchesCountListener);
  }
}

// Fonction pour télécharger l'image vers Firebase Storage
Future<void> uploadImageToFirebaseStorage(Uint8List imageData, String imageName) async {
  try {
    // Référence de votre espace de stockage Firebase
    firebase_storage.Reference storageReference = firebase_storage.FirebaseStorage.instance.ref().child(imageName);

    // Mettez le fichier dans le stockage Firebase
    await storageReference.putData(imageData);

    print('Image uploaded to Firebase Storage successfully');
  } catch (e) {
    print('Error uploading image to Firebase Storage: $e');
  }
}
