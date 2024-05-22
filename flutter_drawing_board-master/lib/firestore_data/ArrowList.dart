import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/firestore_data/ExerciseList%20.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class Arrow {
  final String direction;
  final double size;

  Arrow({required this.direction, required this.size});
}

class ArrowList extends StatefulWidget {

    final List<Arrow> arrows;

  const ArrowList({Key? key, required this.arrows}) : super(key: key);

  @override
  State<ArrowList> createState() => _ArrowListState();
}

class _ArrowListState extends State<ArrowList> {
  late Stream<QuerySnapshot> _arrowsStream;

  @override
  void initState() {
    super.initState();
    _arrowsStream = FirebaseFirestore.instance.collection('arrows').snapshots();
  }

  List<Arrow> parseArrows(List<dynamic> arrowsData) {
    return arrowsData.map((arrowData) {
      return Arrow(
        direction: arrowData['direction'],
        size: arrowData['size'].toDouble(),
      );
    }).toList();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: _arrowsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No arrows available.',
                style: GoogleFonts.lato(
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              List<Arrow> arrows = parseArrows(data['arrows']);

             return Container(
  padding: EdgeInsets.all(8.0), // Ajoute du padding autour du ListTile
  decoration: BoxDecoration( // Ajoute une décoration pour le cadre
    border: Border.all(
      color: Colors.grey, // Couleur de la bordure
      width: 1.0, // Épaisseur de la bordure
    ),
    borderRadius: BorderRadius.circular(8.0), // Coins arrondis du cadre
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligne les éléments horizontalement
    children: [
      Expanded(
        child: Text(
          'Direction: ${data['direction']}',
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Row(
        children: drawArrows(arrows),
      ),
    ],
  ),
);

            },
          );
        },
      ),
    );
  }
}
