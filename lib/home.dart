import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

final mainClient = SupabaseClient(
    'https://srivnnrbfwgahaejaeic.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyaXZubnJiZndnYWhhZWphZWljIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NDc1NjEzMDgsImV4cCI6MTk2MzEzNzMwOH0.wkphUMJcDNu5midB_2SBiBXSsugeT7-PX65l2xwyfOY'
);

var _deviceHeight;
var _deviceWidth;

var _featured;

class home extends StatefulWidget {
  _home createState() => _home();
}

class _home extends State<home> {
  int entryIndex = -1;
  Stream _mainStream = Stream.empty();
  AssetsAudioPlayer _mainPlayer = AssetsAudioPlayer();

  @override
  void initState(){
    super.initState();
    _mainStream = mainClient.from('media-catalog').stream(['id']).order('created', ascending: false).execute();

    _featured = mainClient.from('media-specialty').select().textSearch('name', "'Featured'").execute();

  }

  @override
  void dispose(){
    super.dispose();
  }

  _recentlyBuilder(int index, AsyncSnapshot catalogSnapshot){
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(5.0),
        alignment: Alignment.center,
        height: 125,
        width: 125,
        color: entryIndex == index ? Colors.lightBlue : Colors.grey,
        child: Column(
          children: [
            Expanded(child: Image.asset('bliss-logo.png', width: 95, height: 95, color: Colors.primaries[Random().nextInt(Colors.primaries.length)])),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: FittedBox(child: Text('${catalogSnapshot.data[index]['name']}', style: TextStyle(color: Colors.black))),
              )
          ],
        )

      ),
      onTap: () {
        setState((){
          entryIndex = index;
          final res = mainClient.storage.from('media-bucket').getPublicUrl('${catalogSnapshot.data[index]['bucketid']}');
          final publicURL = res.data;

          _mainPlayer.open(Audio.network('${publicURL}'), showNotification: true
          );
        });
      },
    );
  }

  HOMESCREEN(AsyncSnapshot snapshot){
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ListView(
        children: [
          Column(
            children: [

              Container(
                padding: EdgeInsets.all(5.0),
                alignment: Alignment.centerLeft,
                height: _deviceHeight * 0.05,
                child: Text(
                    "Featured",
                    style: TextStyle(color: Colors.white, fontSize: 20.0)
                ),
              ),

              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    padding: EdgeInsets.all(5.0),
                    color: Colors.deepPurple,
                    alignment: Alignment.center,
                    height: _deviceHeight * 0.30,
                    child: Image.asset('bliss-logo.png', width: double.maxFinite, height: double.maxFinite, color: Colors.amber),
                  ),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(5.0),
                    alignment: Alignment.bottomCenter,
                    child: Text(_featured.toString(), style: TextStyle(color: Colors.black, fontSize: 20.0)),
                  ),
                ],
              ),

              Container(
                padding: EdgeInsets.all(5.0),
                alignment: Alignment.centerLeft,
                height: _deviceHeight * 0.05,
                child: Text(
                  "Recently Added",
                  style: TextStyle(color: Colors.white, fontSize: 20.0)
                ),
              ),
  
              Container(
                height: _deviceHeight * 0.20,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(width: 10.0);
                    },
                    padding: EdgeInsets.all(10.0),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _recentlyBuilder(index, snapshot);
                    },
                ),
              ),

          ],
        ),
      ],
    ),
    );
  }

  @override
  Widget build(BuildContext context) {

    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return StreamBuilder(
        stream: _mainStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(backgroundColor: Colors.black ,body: Center(child: CircularProgressIndicator(color: Colors.lightBlue)));
          } else if (snapshot.hasData) {
            return Scaffold(
              body: Container(
                decoration: const BoxDecoration(color: Colors.black),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: HOMESCREEN(snapshot),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  _mainPlayer.playOrPause();
                },
                backgroundColor: Colors.lightBlue,
                child: const Icon(Icons.music_note),
              ),
            );
          } else {
            return Container(color: Colors.black ,child: Center(child: Text('Something has gone wrong...', style: TextStyle(color: Colors.white, fontSize: 16.0))));
          }
        }
    );
  }
}