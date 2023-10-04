import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imgpic;

class SplitImageGame extends StatefulWidget {
  const SplitImageGame({Key? key}) : super(key: key);

  @override
  State<SplitImageGame> createState() => _SplitImageGameState();
}

List<imgpic.Image> splitImage(imgpic.Image image,int numRows,int numCols){

  List<imgpic.Image> imagePieces = [];

  final pieceWidth = image.width ~/ numCols;
  final pieceHeight = image.height ~/ numRows;

  for(int row = 0; row < numRows; row++){
    for(int col = 0; col < numCols; col++){
      final x = col * pieceWidth;
      final y = row * pieceHeight;
      final piece = imgpic.copyCrop(image, x: x, y: y, width: pieceWidth, height: pieceHeight);
      imagePieces.add(piece);
    }
  }
  return imagePieces;
}

class _SplitImageGameState extends State<SplitImageGame> {

  List<imgpic.Image> imagePieces = [];
  List<int> correctOrder = [];

  // List<imgpic.Image> splitImage(imgpic.Image image,int numRows,int numCols){
  //
  //   List<imgpic.Image> imagePieces = [];
  //
  //   final pieceWidth = image.width ~/ numCols;
  //   final pieceHeight = image.height ~/ numRows;
  //
  //   for(int row = 0; row < numRows; row++){
  //     for(int col = 0; col < numCols; col++){
  //       final x = col * pieceWidth;
  //       final y = row * pieceHeight;
  //       final piece = imgpic.copyCrop(image, x, y, pieceWidth, pieceHeight);
  //       imagePieces.add(piece);
  //     }
  //   }
  //   return imagePieces;
  // }

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() async {
    // Load the main image

    final ByteData data = await rootBundle.load('img/taj mahal.png');
    final List<int> bytes = data.buffer.asUint8List();
    final imgpic.Image mainImage = imgpic.decodeImage(Uint8List.fromList(bytes))!;

    // Split the Main Image into the Pieces

    final numRows = 3;
    final numCols = 3;
    imagePieces = splitImage(mainImage, numRows, numCols);

    // Create the correct order of piece indices

    correctOrder = List.generate(numRows * numCols, (index) => index);
    correctOrder.shuffle();
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Split Images Game"),
        centerTitle: true,
      ),
      body: GridView.builder(
        itemCount: imagePieces.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          final pieceIndex = correctOrder[index];
          return DragTarget<int>(
            builder: (context, candidateData, rejectedData) {
              return Draggable(
                data: pieceIndex,
                  child: Image.memory(Uint8List.fromList(imagePieces[pieceIndex].getBytes())), 
                  feedback: Image.memory(Uint8List.fromList(imagePieces[pieceIndex].getBytes())),
              );
          },
            onWillAccept: (data) {
              return data == pieceIndex;
            },
            onAccept: (data) {
              setState(() {
                correctOrder.remove(data);
                correctOrder.insert(index, data);
              });
            },
          );
      },),
    );
  }
}
