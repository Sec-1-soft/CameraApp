import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:kamera/displayImage.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(CameraApp());

class CameraApp extends StatelessWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
        primaryColorDark: Colors.white,
        primaryColorLight: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: CameraScaffold(),
    );
  }
}

class CameraScaffold extends StatefulWidget {
  const CameraScaffold({Key? key}) : super(key: key);

  @override
  State<CameraScaffold> createState() => _CameraScaffoldState();
}

class _CameraScaffoldState extends State<CameraScaffold> {
  CameraController? _controller;
  late bool _isLand;
  double initialScale = 1;
  double currentScale = 1;
  FlashMode flashMode = FlashMode.off;
  bool _isLight = false;
  int camera_id = 0;
  TransformationController transform_controller = TransformationController();

  Future<void> startCamera(int i) async {
    final cameras = await availableCameras();
    final camera = cameras[i];
    _controller = CameraController(camera, ResolutionPreset.ultraHigh);
    _controller!.setFocusMode(FocusMode.auto);
    if (_controller != null || _controller != "") {
      await initializeCamera();
    }
    setState(() {});
  }

  Future<void> initializeCamera() async {
    if (_controller != null) {
      await _controller!.initialize();
    }
  }

  Future<void> disposeCamera() async {
    await _controller!.dispose();
  }



  @override
  void initState() {
    super.initState();
    hideSystemUi();
    startCamera(camera_id);
  }

  @override
  void dispose() {
    disposeCamera();
    super.dispose();
  }

  void hideSystemUi() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> savePicture() async {
    final image = await _controller!.takePicture();
    Directory? dir = await getExternalStorageDirectory();
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + ".png";
    File file = File("${dir!.path}/$fileName");
    await file.writeAsBytes(await image.readAsBytes());
    if(file.existsSync()){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Resim Kayıt edildi.")));
    }
  }

  Future<void> Light(flashMode) async{
    if(_controller != null || _controller!.value.isInitialized){
      _controller!.setFlashMode(flashMode);
    }
  }



  @override
  Widget build(BuildContext context) {
    bool isRight = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed:(){
                if(camera_id == 0){
                  setState(() {
                    camera_id = 1;
                    startCamera(camera_id);
                  });
                }else if(camera_id == 1){
                  setState(() {
                    camera_id = 0;
                    startCamera(camera_id);
                  });
                }
              }, icon:Icon(Icons.cameraswitch_sharp,
              color: Colors.white,
              )),
            ],
          ),
          toolbarHeight: 35,
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: _controller != null
              ? _controller!.value.isInitialized || _controller != null
              ? ListView(
            children: [
              GestureDetector(
                onTap: (){
                  _controller!.setFocusMode(FocusMode.auto);
                },
                onScaleStart: (details) {
                  initialScale = currentScale;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    currentScale = initialScale * details.scale;
                    if(currentScale > 5){
                      currentScale = 5;
                    }else if(currentScale < 1){
                      currentScale = 1;
                    }
                  });
                },
                onScaleEnd: (details) {
                 if(currentScale >= 1 && currentScale<5){
                   _controller!.setZoomLevel(currentScale);
                 }
                },
                child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: AspectRatio(
                        aspectRatio: 9/16,
                        child: CameraPreview(_controller!))),
              )
            ],
          )
              : CircularProgressIndicator()
              : SizedBox(),
        ),
        floatingActionButton: Container(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.only(
            left: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: IconButton(onPressed:(){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder:(BuildContext context){
                    return open_image();
                  }));
                }, icon:Icon(Icons.image,
                color: Colors.white,
                )),
              ),
              FloatingActionButton(
                onPressed: () {
                  savePicture();
                },
                child: Icon(Icons.camera_alt,
                color: Colors.black,
                ),
                backgroundColor: Colors.white,
              ),
              Container(
                child: IconButton(onPressed:(){
                  setState(() {

                   if(flashMode == FlashMode.off){
                     _isLight = true;
                     flashMode = FlashMode.torch;
                   }else if(flashMode == FlashMode.torch){
                     _isLight = false;
                     flashMode = FlashMode.off;
                   }
                   Light(flashMode);
                  });
                }, icon: _isLight ? Icon(Icons.flash_on,
                color: Colors.white,
                ):Icon(Icons.flash_off,
                color: Colors.white,
                )),
              )
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}


class open_image extends StatefulWidget {
  const open_image({super.key});

  @override
  State<open_image> createState() => _open_imageState();
}

class _open_imageState extends State<open_image> {
  @override

  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async{
        setState(() {

        });
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed:(){
            Navigator.pushReplacement(context, MaterialPageRoute(builder:(BuildContext context) {
              return CameraScaffold();
            },));
          }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
          backgroundColor: Colors.black,
          title: Text("Galeri",
          style: TextStyle(
            color: Colors.white,
          ),
          ),
        ),
        body: FutureBuilder(future:openImage(), builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(),
            );
          }else if(snapshot.hasError){
            return Column(
              children: [
               CircularProgressIndicator(),
               Text("Hata Oluştu"),
              ],
            );
          }else{
            return Column(
              children: [
                SizedBox(height: 10,),
                Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder:(BuildContext context,index){
                        return Container(
                          child: Column(
                            children: [
                              SizedBox(height: 4,),
                              ListTile(
                                leading: AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.file(File(snapshot.data![index].path),
                                  fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(snapshot.data![index].path.split("/").last,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                                ),
                                onTap: (){
                                   Navigator.push(context, MaterialPageRoute(builder:(BuildContext context) {
                                     return DisplayImage(path: snapshot.data![index].path);
                                   },));
                                },
                              ),
                              SizedBox(height: 4,),
                              Divider(height: 1.0,color: Colors.black12,),
                            ],
                          ),
                        );
                  }),
                ),
              ],
            );
          }
        },)
      ),
    );
  }
}

Future<List<FileSystemEntity>> openImage() async{
  Directory? dir = await getExternalStorageDirectory();
  List<FileSystemEntity> files = dir!.listSync();
  return files;
}
