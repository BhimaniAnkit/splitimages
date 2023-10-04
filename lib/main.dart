import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imgpic;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: first(),
  ));
}

class first extends StatefulWidget {
  const first({Key? key}) : super(key: key);

  @override
  State<first> createState() => _firstState();
}

class _firstState extends State<first> {

  List img = [];
  List img1 = [];
  bool temp = false;

  List<bool> tmp = [];

  List<imgpic.Image> splitImage(imgpic.Image inputImage, int horizontalPieceCount, int verticalPieceCount) {
    imgpic.Image image = inputImage;

    final pieceWidth = (image.width / horizontalPieceCount).round();
    final pieceHeight = (image.height / verticalPieceCount).round();
    final pieceList = List<imgpic.Image>.empty(growable: true);
    int x = 0,y = 0;
    for (int i = 0;i < horizontalPieceCount; i++) {
      for (int j = 0;j < verticalPieceCount; j++) {
        pieceList.add(imgpic.copyCrop(image, x: x, y: y, width: pieceWidth, height: pieceHeight));

        x = x + pieceWidth;
      }
      x = 0;
      y = y + pieceHeight;
    }
    return pieceList;
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('img/$path');

    var dir_path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS)+"/folder";
    print(path);

    Directory dir = Directory(dir_path);

    if(! await dir.exists()){
      dir.create();
    }

    final file = File('${dir.path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  @override
  void initState() {
    permission();
    getImageFileFromAssets("nature1.jpg").then((value){
      print(value);

      imgpic.Image? myimage = imgpic.decodeJpg(value.readAsBytesSync());

      img = splitImage(myimage!, 3, 3);

      for(int i = 0; i < img.length; i++){
         img1.add(Image.memory(imgpic.encodeJpg(img[i])));
      }
      img1.shuffle();
      temp = true;
      tmp = List.filled(9, true);

      setState(() {

      });
    });
  }

  permission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.storage,
      ].request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Split Images Demo",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
      body: (temp) ? GridView.builder(
        itemCount: img1.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2),
        itemBuilder: (context, index) {
          return (tmp[index])
              ? Draggable(
            data: index,
              onDragStarted: () {
                tmp = List.filled(9, false);
                tmp[index] = true;
                setState(() {

                });
              },
              onDragEnd: (details) {
                tmp = List.filled(9, true);
                setState(() {

                });
              },
              child: img1[index], feedback: img1[index] )
              : DragTarget(
            onAccept: (data) {
              var c = img1[data as int];
              img1[data as int] = img1[index];
              img1[index] = c;
              setState(() {

              });
            },
            builder: (context, candidateData, rejectedData) {
              return img1[index];
              },
          );
      },) : CircularProgressIndicator(),
    );
  }
}
