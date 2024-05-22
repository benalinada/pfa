import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/firestore_data/ArrowList.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

class ExerciseList extends StatefulWidget {
  const ExerciseList({Key? key}) : super(key: key);

  @override
  State<ExerciseList> createState() => _ExerciseListState();
}

  List<Arrow> parseArrows(List<dynamic> arrowsData) {
    return arrowsData.map((arrowData) {
      return Arrow(
        direction: arrowData['direction'],
        size: arrowData['size'].toDouble(),
      );
    }).toList();
  }

   

class _ExerciseListState extends State<ExerciseList> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('arrows').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot exercise = snapshot.data!.docs[index];
               Map<String, dynamic> data = exercise.data() as Map<String, dynamic>;
              List<Arrow> arrows = parseArrows(data['arrows']);
              return Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Card(
                  color: Colors.blue[50],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 9,
                    child: TextButton(
                     onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //           builder: (context) => ArrowList(arrows :arrows),
                        //   ),
                        // );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 25,
                            child: Icon(
                              Icons.fitness_center,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  exercise['direction'],
                                  style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                         
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
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
}

class Arrow {
  final String direction;
  final double size;

  Arrow({required this.direction, required this.size});
}
