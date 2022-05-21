import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:path_provider/path_provider.dart';

import 'uvplayer.dart';

final mainClient = SupabaseClient(
    'https://srivnnrbfwgahaejaeic.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyaXZubnJiZndnYWhhZWphZWljIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NDc1NjEzMDgsImV4cCI6MTk2MzEzNzMwOH0.wkphUMJcDNu5midB_2SBiBXSsugeT7-PX65l2xwyfOY'
);

var _deviceHeight;
var _deviceWidth;

List<String> _localCatalog = [];

class play extends StatefulWidget {
  late final String blissPath;
  play({required this.blissPath});

  @override
  _play createState() => _play(this.blissPath);
}

class _play extends State<play> {
  String _blissPath = '';
  _play(this._blissPath);

  Stream _mainStream = Stream.empty();
  int entryIndex = -1;
  TextEditingController searchController = TextEditingController();
  TextEditingController notesController = TextEditingController(text: 'Notes...');

  @override
  void initState(){
    super.initState();
    _mainStream = mainClient.from('media-catalog').stream(['id']).execute();
    searchController.addListener(_updateSearch);
  }

  @override
  void dispose(){
    super.dispose();
    searchController.removeListener(_updateSearch);
    searchController.dispose();
    _localCatalog.clear();
  }

  _readLocal(AsyncSnapshot catalogSnapshot) async{
    await Directory(_blissPath).list(recursive: false).forEach((f) {
      _localCatalog.add(basename(f.path));
    });
    //print(_localCatalog);
    _updateSearch();
  }

  _updateSearch(){
    setState(() {});
  }

  _catalogBuilder(int index, AsyncSnapshot catalogSnapshot){
    return Container(
      alignment: Alignment.center,
      height: 80,
      color: entryIndex == index ? Colors.lightBlue : Colors.grey,
      child: ListTile(
        leading: Text('${catalogSnapshot.data[index]['type']}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        title: Text('${catalogSnapshot.data[index]['name']}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        subtitle: Text('${catalogSnapshot.data[index]['category']}', style: TextStyle(color: Colors.black)),
        isThreeLine: true,
        dense: true,
        onTap: () {
          setState((){
            entryIndex = index;

            universalPlayer.player.open(Audio.file('${_blissPath}/${catalogSnapshot.data[index]['bucketid']}', metas: Metas(
                title: catalogSnapshot.data[index]['name'],
                artist: catalogSnapshot.data[index]['category'],
                image: MetasImage.asset('bliss-logo.png'))),
                showNotification: true
            );
            universalPlayer.playerIcon = Icon(Icons.pause);
            setState(() {});

          });
        },
      ),
    );
  }

  PLAY_LIST(AsyncSnapshot catalogSnapshot){
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
/*          Container(
            height: 50,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))
              ),
            ),
          ),*/

          Container(
            height: MediaQuery.of(this.context).size.height - 180,
            child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) {
                  if(_localCatalog.contains(catalogSnapshot.data[index]['bucketid'].toString().toLowerCase())){
                    return SizedBox(height: 5.0);
                  }
                  return SizedBox.shrink();
                },
                padding: EdgeInsets.all(5.0),
                itemCount: catalogSnapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  if(_localCatalog.contains(catalogSnapshot.data[index]['bucketid'].toString().toLowerCase())){
                    return _catalogBuilder(index, catalogSnapshot);
                  }
                  return SizedBox.shrink();
                }
            ),
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
            _readLocal(snapshot);
            return Scaffold(
              body: Container(
                decoration: const BoxDecoration(color: Colors.black),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: PLAY_LIST(snapshot),
              ),
            );
          } else {
            return Container(color: Colors.black ,child: Center(child: Text('Something has gone wrong...', style: TextStyle(color: Colors.white, fontSize: 16.0))));
          }
        }
    );
  }
}