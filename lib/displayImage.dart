import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kamera/main.dart';



class DisplayImage extends StatefulWidget {
  String path = "";
  DisplayImage({required this.path});

  @override
  State<DisplayImage> createState() => _DisplayImageState();
}

class _DisplayImageState extends State<DisplayImage> {
  double initialScale = 0.1; //Başlangıçtaki yakınlık
  double currentScale = 1.0; //Yakınlaştırma değeri

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.path.split("/").last,
        style: TextStyle(
          color: Colors.white,
        ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            GestureDetector(
              child: AspectRatio(
                aspectRatio: 9/16,
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    child:  InteractiveViewer(
                      boundaryMargin: EdgeInsets.all(0),
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Transform.scale(
                        scale: currentScale,
                        child: Image.file(
                          File(widget.path),
                          fit: BoxFit.contain, // Resmi tam olarak sığdır
                        ),
                      ),
                    ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed:(){
              showDialog(context: context, builder: (context) {
                return AlertDialog(
                  title: Text("Uyarı"),
                  content: Text("Bu resmi silmek istiyormusun ?"),
                  actions: [
                    ElevatedButton(onPressed:(){
                      File file = File(widget.path);
                      file.delete();
                      Navigator.pop(context);
                      Navigator.of(context).pop();
                    }, child: Text("Tamam",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    ),
                    ElevatedButton(onPressed:(){
                      Navigator.pop(context);
                    }, child: Text("İptal",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    ),
                  ],
                );
              },);
            }, icon: Icon(Icons.delete,
            color: Colors.white,
            )),
            IconButton(onPressed:(){
            }, icon: Icon(Icons.share,
            color: Colors.white,
            )),
          ],
        ),
      )
    );
  }
}
