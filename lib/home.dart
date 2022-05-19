import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

import 'uvplayer.dart';

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

  @override
  void initState(){
    super.initState();
    _mainStream = mainClient.from('media-catalog').stream(['id']).order('created', ascending: false).execute();
  }

  @override
  void dispose(){
    super.dispose();
  }

  _homeBuilder(int index, AsyncSnapshot snapshot){
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(5.0),
        alignment: Alignment.center,
        height: 125,
        width: 125,
        color: Colors.grey,
        child: Column(
          children: [
            Expanded(child: Image.asset('bliss-logo.png', width: 95, height: 95, color: Colors.primaries[Random().nextInt(Colors.primaries.length)])),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: FittedBox(child: Text('${snapshot.data[index]['name']}', style: TextStyle(color: Colors.black))),
              )
          ],
        )

      ),
      onTap: () {
        setState((){
          entryIndex = index;
          final res = mainClient.storage.from('media-bucket').getPublicUrl('${snapshot.data[index]['bucketid']}');
          final publicURL = res.data;

          universalPlayer.player.open(Audio.network('${publicURL}', metas: Metas(
              title: snapshot.data[index]['name'],
              artist: snapshot.data[index]['category'],
              image: MetasImage.asset('bliss-logo.png'))),
              showNotification: true
          );
          universalPlayer.playerIcon = Icon(Icons.pause);
          setState(() {});

        });
      },
    );
  }

  HOMESCREEN(AsyncSnapshot snapshot){

    for(int index = 0; index < snapshot.data.length; index++){
      if(snapshot.data[index]['sp_flag'].toString().contains('f')){
        _featured = snapshot.data[index];
      }
    }

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ListView(
        children: [
          Column(
            children: [

              // Featured Header
              Container(
                padding: EdgeInsets.all(5.0),
                alignment: Alignment.centerLeft,
                height: _deviceHeight * 0.05,
                child: Text("Featured", style: TextStyle(color: Colors.white, fontSize: 20.0)),
              ),

              // Featured Display & Banner
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
                    child: Text(_featured['name'].toString(), style: TextStyle(color: Colors.black, fontSize: 20.0)),
                  ),
                ],
              ),

              // Recently Added Header
              Container(
                padding: EdgeInsets.all(10.0),
                alignment: Alignment.centerLeft,
                height: _deviceHeight * 0.05,
                child: Text("Recently Added", style: TextStyle(color: Colors.white, fontSize: 18.0)),
              ),

              // Recently Added List (Most Recent Twenty Here)
              Container(
                height: _deviceHeight * 0.25,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(width: 10.0);
                    },
                    padding: EdgeInsets.all(10.0),
                    itemCount: snapshot.data.length - 1 < 20 ? snapshot.data.length : 20,
                    itemBuilder: (BuildContext context, int index) {
                      return _homeBuilder(index, snapshot);
                    },
                ),
              ),

              // Developer's Picks Header
              Container(
                padding: EdgeInsets.all(10.0),
                alignment: Alignment.centerLeft,
                height: _deviceHeight * 0.05,
                child: Text("Developer's Picks", style: TextStyle(color: Colors.white, fontSize: 18.0)),
              ),

              // Developer's Picks (Only Five AT MOST)
              Container(
                height: _deviceHeight * 0.25,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(width: 10.0);
                  },
                  padding: EdgeInsets.all(10.0),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    if(snapshot.data[index]['sp_flag'].toString().contains('dp')) {
                      return _homeBuilder(index, snapshot);
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
          ])
      ])
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
            );
          } else {
            return Container(color: Colors.black ,child: Center(child: Text('Something has gone wrong...', style: TextStyle(color: Colors.white, fontSize: 16.0))));
          }
        }
    );
  }
}