import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home.dart';
import 'browse.dart';
import 'upload.dart';
import 'player.dart';
import 'uvplayer.dart';

Widget _body = Container();
bool _introLaunch = false;

_blissIntro(AnimationController _controller, Animatable<Color?> background){
  return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          body: Container(
              color: background.evaluate(AlwaysStoppedAnimation(_controller.value)),
              child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Enter Bliss.', style: TextStyle(color: Colors.white, fontSize: 40.0)),
                      Image.asset('bliss-logo.png', width: 200, height: 200, color: Colors.white),
                      Column(children: [
                        Text('The definitive auditory-response experience.', style: TextStyle(color: Colors.white, fontSize: 12.0), textAlign: TextAlign.center),
                        Text('Empowered by the community.', style: TextStyle(color: Colors.white, fontSize: 12.0), textAlign: TextAlign.center),
                        Text('Empowered for the community.', style: TextStyle(color: Colors.white, fontSize: 12.0), textAlign: TextAlign.center),
                      ],),
                      Text('Use the navigation button at the top left to get around. Thank you for your support!', style: TextStyle(color: Colors.white, fontSize: 8.0), textAlign: TextAlign.center),
                    ],
                  )
              )
          ),
        );
      }
  );
}

_firstLaunch() async {
  Directory _blissPath = await getApplicationDocumentsDirectory();
  bool localExists = await Directory('${_blissPath.path}/local_catalog').exists();
  if(!localExists){
    _introLaunch = true;
  }
}

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://srivnnrbfwgahaejaeic.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyaXZubnJiZndnYWhhZWphZWljIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NDc1NjEzMDgsImV4cCI6MTk2MzEzNzMwOH0.wkphUMJcDNu5midB_2SBiBXSsugeT7-PX65l2xwyfOY'
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bliss',
      theme: ThemeData(primarySwatch: Colors.grey),
      home: MyHomePage(title: 'Bliss'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  State<MyHomePage> createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  var _controller;

  Animatable<Color?> background = TweenSequence<Color?>([
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.red,
        end: Colors.green,
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.green,
        end: Colors.blue,
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.blue,
        end: Colors.pink,
      ),
    ),
  ]);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _firstLaunch();

    if(_introLaunch) {
      _body = _blissIntro(_controller, background);
    }else{
      _body = home();
      _appbar = 'Bliss - Home';
      setState(() {});
    }
  }

  String _appbar = 'Bliss - Intro';
  String _version = '1.0';

  _update(){
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(),
      body: _body,
      drawer: Drawer(
        child: Column(
          children: [
            ListTile(
              title: const Text('Home'),
              onTap: () {
                // Update the state of the app
                _body = home();
                _appbar = 'Bliss - Home';
                setState(() {});
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Browse'),
              onTap: (){
                // Update the state of the app
                _body = browse();
                _appbar = 'Bliss - Browse';
                setState(() {});
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Play'),
              onTap: () async {
                Directory _blissPath = await getApplicationDocumentsDirectory();
                bool localExists = await Directory('${_blissPath.path}/local_catalog').exists();

                if(!localExists){
                  new Directory('${_blissPath.path}/local_catalog').create();
                }

                // Update the state of the app
                _body = play(blissPath: '${_blissPath.path}/local_catalog');
                _appbar = 'Bliss - Play';
                setState(() {});
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Upload'),
              onTap: (){
                // Update the state of the app
                _body = upload();
                _appbar = 'Bliss - Upload';
                setState(() {});
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text('Version: v${_version}'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          universalPlayer.player.playOrPause();
          setState(() {});
        },
        backgroundColor: Colors.lightBlue,
        child: universalPlayer.playerIcon,
      ),
    );
  }
}