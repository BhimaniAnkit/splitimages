import 'package:flutter/material.dart';

class third extends StatefulWidget {
  const third({Key? key}) : super(key: key);

  @override
  State<third> createState() => _thirdState();
}

class _thirdState extends State<third> {

  List<Widget> imagePieces = [];


  @override
  void initState() {
    super.initState();
    splitImage();
  }

  void splitImage(){
    // Load the main image
    AssetImage assetImage = AssetImage("img/taj mahal.png"); // Replace with your image path
    Image image = Image(image: assetImage);
    // Split the image into pieces

    int numRows = 3;
    int numCols = 3;
    double pieceWidth = image.width! / numCols;
    double pieceHeight = image.height! / numRows;

    for(int row = 0; row < numRows; row++){
      for(int col = 0; col < numCols; col++){
        Rect sliceRect = Rect.fromLTWH(col * pieceWidth, row * pieceHeight, pieceWidth, pieceHeight);
        Image slicedImage = Image.asset('img/taj mahal.png',
        width: pieceWidth,
          height: pieceHeight,
          fit: BoxFit.fill,
          alignment: Alignment(-sliceRect.left / pieceWidth, -sliceRect.top / pieceHeight),
        );
        imagePieces.add(
            Draggable<int>(
              data: row * numCols + col,
              child: slicedImage,
              feedback: Material(
                child: ConstrainedBox(
                  constraints: BoxConstraints.tight(Size(pieceWidth, pieceHeight)),
                  child: slicedImage,
                ),
              ),
              childWhenDragging: Container(),
            ));
      }
    }
  }

  bool _isPuzzleSolved(){
    for(int i = 0; i < imagePieces.length; i++){
      if(imagePieces[i] != i){
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Split Images Game'),
        centerTitle: true,
      ),
      body: Center(
        child: _isPuzzleSolved()
            ? Text('Puzzle Solved!',
              style: TextStyle(fontSize: 24),
              )
            : GridView.builder(
                itemCount: imagePieces.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3
                ),
                itemBuilder: (context, index) {
                  return imagePieces[index];
                  },
                ),
      ),
    );
  }
}
