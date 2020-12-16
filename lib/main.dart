import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_radio_player/flutter_radio_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  var playerState = FlutterRadioPlayer.flutter_radio_paused;

  var volume = 0.8;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterRadioPlayer _flutterRadioPlayer = new FlutterRadioPlayer();

  @override
  void initState() {
    initRadioService();
    super.initState();
  }

  Future<void> initRadioService() async{
    try{
      await _flutterRadioPlayer.init("Radio Islami", "Streamer Radio", "http://185.47.62.52:8000/;", "false");
    }on PlatformException{
      print("Error Playing");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        appBar: AppBar(title: Text("Radio Islami"),),
        body: Center(
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: Icon(
                  Icons.radio,
                  size: 250,
                  color: Colors.blue,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Icon(Icons.volume_up, color: Colors.blue),
                    Expanded(
                      child: Slider(
                        value: widget.volume,
                        min: 0,
                        max: 1.0,
                        onChanged: (value) => setState((){
                          widget.volume = value;
                          _flutterRadioPlayer.setVolume(widget.volume);
                        }),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0 , bottom: 32.0),
                    child: StreamBuilder(
                      stream: _flutterRadioPlayer.isPlayingStream,
                      initialData: widget.playerState,
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                        String returnData = snapshot.data;
                        print("Object Data" + returnData);
                        switch(returnData){
                          case FlutterRadioPlayer.flutter_radio_paused:
                            return RaisedButton(
                              color: Colors.blue,
                              child: Text("Start Listening now", style: TextStyle(color: Colors.white)),
                              onPressed: () async{
                                await initRadioService();
                              },
                            );
                            break;
                          case FlutterRadioPlayer.flutter_radio_loading:
                          case FlutterRadioPlayer.flutter_radio_error:
                            return RaisedButton(
                              color: Colors.blue,
                              child: Text("Retry ?", style: TextStyle(color: Colors.white),),
                              onPressed: () async {
                                await initRadioService();
                              },
                            );
                            break;
                          default:
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FloatingActionButton(
                                  child: snapshot.data == FlutterRadioPlayer.flutter_radio_playing ? Icon(Icons.pause): Icon(Icons.play_arrow),
                                  onPressed: () async{
                                    await _flutterRadioPlayer.playOrPause();
                                  },
                                ),
                                SizedBox(width: 16,),
                                FloatingActionButton(
                                  child: Icon(Icons.stop),
                                  onPressed:() async {
                                    await _flutterRadioPlayer.stop();
                                },
                                )
                              ],
                            );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
