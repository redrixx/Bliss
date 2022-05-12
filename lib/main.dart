import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home.dart';
import 'browse.dart';
import 'upload.dart';
import 'uvplayer.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  Widget _body = Container(color: Colors.black, child: Center(
      child: Text('Welcome to Bliss. Reveal the navigation pane at the top left to get started.', style: TextStyle(color: Colors.white, fontSize: 16.0))
  ));

  String _appbar = 'Bliss - Intro';
  String _version = '0.1a';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appbar),
        actions: <Widget>[

          // IconButton(
          //   icon: Icon(
          //     Icons.refresh,
          //     color: Colors.black,
          //   ),
          //   onPressed: () {
          //     setState(() {
          //     });
          //   },
          // )

        ],
      ),
      body: _body,
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
              child: Image.asset('bliss-logo.png'),
            ),
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
              onTap: (){
                // Update the state of the app
                _body = Container(color: Colors.black ,child: Center(
                    child: Text('Play not implemented.', style: TextStyle(color: Colors.white, fontSize: 16.0))
                ));
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
          if(universalPlayer.playerIcon.icon != Icons.music_note){
            if(universalPlayer.playerIcon.icon == Icons.play_arrow){
              universalPlayer.playerIcon = Icon(Icons.pause);
            }else{
              universalPlayer.playerIcon = Icon(Icons.play_arrow);
            }
          }
          universalPlayer.player.playOrPause();
          setState(() {});
        },
        backgroundColor: Colors.lightBlue,
        child: universalPlayer.playerIcon,
      ),
    );
  }
}