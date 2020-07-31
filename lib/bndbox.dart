import 'package:appra/recognizableobject.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:appra/main.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

CameraController controller;

class BndBox extends StatelessWidget {
  final List<dynamic> results;
  final List<RecognizableObject> descriptions;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;
  final int model;

  BndBox(this.results, this.previewH, this.previewW, this.screenH, this.screenW,
      this.model, this.descriptions);

  @override
  Widget build(BuildContext context) {
    List<Widget> _renderStrings() {
      return results.map((re) {
        if (re["confidence"] > 0.9) {
          var description = "";
          if (descriptions != null) {
            var recognizedobject = descriptions
                .firstWhere((element) => element.label == re["label"]);
            if (recognizedobject != null) {
              description = recognizedobject.description;
            }
          }
          return SlidingUpPanel(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            panel: Container(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "${re["label"]} ${(re["confidence"] * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 12.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Positioned(
                        child: new RaisedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => new MyApp()),
                            );
                          },
                          color: Colors.blue,
                          textColor: Color.fromRGBO(255, 255, 255, 1),
                          child: Text("Fechar"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Container(
            width: 0.0,
            height: 0.0,
          );
        }
      }).toList();
    }

    return Stack(
      children: model == model
          ? _renderStrings()
          : model == model ? _renderStrings() : _renderStrings(),
    );
  }
}
