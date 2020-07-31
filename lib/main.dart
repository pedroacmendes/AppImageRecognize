import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:appra/recognizableobject.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:screen/screen.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'camera.dart';
import 'bndbox.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'model.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  Screen.keepOn(true);
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: HomePage(cameras),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  int _model = -1;
  String dataLabel;
  String dataModel;
  List<RecognizableObject> modelDescriptions = new List<RecognizableObject>();
  List<Model> availableModels = new List<Model>();
  String localPath;
  String apiroot = "http://192.168.1.7:4000";

  @override
  void initState() {
    super.initState();
    getLocalPath();
    getPedidos();
  }

  getDescriptions(int id) async {
    var response = await http.get(apiroot + "/description/" + id.toString());
    modelDescriptions = (json.decode(response.body) as List)
        .map((i) => RecognizableObject.fromJson(i))
        .toList();
  }

  getLocalPath() async {
    final directory = await getExternalStorageDirectory();
    localPath = directory.path;
  }

  getPedidos() async {
    http.Response response = await http.get(apiroot + "/listOrders");
    var _availableModels = (json.decode(response.body) as List)
        .map((i) => Model.fromJson(i))
        .toList();

    setState(() {
      availableModels = _availableModels;
    });
  }

  Future<String> getLabel(int id) async {
    http.Response responseLabel =
        await http.get(apiroot + '/labels/' + id.toString());
    return responseLabel.body;
  }

  Future<Uint8List> getModelo(int id) async {
    http.Response responseModel =
        await http.get(apiroot + '/model/' + id.toString());
    return responseModel.bodyBytes;
  }

  File get _localFileModel {
    final path = localPath;
    return File('$path/model.tflite');
  }

  File get _localFileLabel {
    final path = localPath;
    return File('$path/labels.txt');
  }

  Future<File> writeContentLabel(int id) async {
    final file = _localFileLabel;
    String label = await getLabel(id);
    return file.writeAsString(label);
  }

  Future<File> writeContentModel(int id) async {
    final file = _localFileModel;
    Uint8List model = await getModelo(id);
    return file.writeAsBytes(model);
  }

  loadModel(int modelID) async {
    await getDescriptions(modelID);

    await writeContentLabel(modelID);
    await writeContentModel(modelID);

    var lab = localPath + '/labels.txt';
    var mod = localPath + '/model.tflite';
    String res;

    res = await Tflite.loadModel(
      model: '$mod',
      labels: '$lab',
      isAsset: false,
    );

    print(res);
  }

  onSelect(modelID) async {
    await loadModel(modelID);
    setState(() {
      _model = modelID;
    });
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

    List<Widget> buttons = new List<Widget>();

    availableModels.forEach((element) {
      buttons.add(RaisedButton(
        child: Text("Pedido " + element.request_id.toString()),
        onPressed: () => onSelect(element.request_id),
        color: Color.fromRGBO(0, 0, 255, 0.7),
        textColor: Color.fromRGBO(255, 255, 255, 1),
      ));
    });
    return MaterialApp(
      home: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text("App RA"),
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.4),
            elevation: 0.0,
          ),
          body: _model == -1
              ? Container(
                  width: 500,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/background2.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buttons,
                  ),
                )
              : Stack(
                  children: [
                    Camera(
                      widget.cameras,
                      _model,
                      setRecognitions,
                    ),
                    BndBox(
                      _recognitions == null ? [] : _recognitions,
                      math.max(_imageHeight, _imageWidth),
                      math.min(_imageHeight, _imageWidth),
                      screen.height,
                      screen.width,
                      _model,
                      modelDescriptions,
                    ),
                  ],
                )),
    );
  }
}
