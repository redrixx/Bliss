import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

import 'player.dart';

final mainClient = SupabaseClient(
    'https://srivnnrbfwgahaejaeic.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyaXZubnJiZndnYWhhZWphZWljIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NDc1NjEzMDgsImV4cCI6MTk2MzEzNzMwOH0.wkphUMJcDNu5midB_2SBiBXSsugeT7-PX65l2xwyfOY'
);

class browse extends StatefulWidget {
  _browse createState() => _browse();
}

class _browse extends State<browse> {
  Stream _mainStream = Stream.empty();
  int entryIndex = -1;
  TextEditingController searchController = TextEditingController();
  TextEditingController notesController = TextEditingController(text: 'Notes...');


  List<DropdownMenuItem<String>> _generateList(AsyncSnapshot catalogSnapshot, String criteria){
    List<String> _itemList = [];
    for(int x = 0; x < catalogSnapshot.data.length; x++){
      _itemList.add(catalogSnapshot.data[x][criteria]);
    }
    _itemList = _itemList.toSet().toList();
    _itemList.sort();

    List<DropdownMenuItem<String>> _itemListMenu = [];
    for(int x = 0; x < _itemList.length; x++){
      _itemListMenu.add(DropdownMenuItem(child: Text('${_itemList[x]}'), value: '${_itemList[x]}'));
    }
    return _itemListMenu;
  }

  @override
  void initState(){
    super.initState();
    _mainStream = mainClient.from('media-catalog').stream(['id']).order('type', ascending: true).execute();
    searchController.addListener(_updateSearch);
  }

  @override
  void dispose(){
    searchController.removeListener(_updateSearch);
    searchController.dispose();
    super.dispose();
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
            final res = mainClient.storage.from('media-bucket').getPublicUrl('${catalogSnapshot.data[index]['bucketid']}');
            final publicURL = res.data;

            universalPlayer.player.open(Audio.network('${publicURL}', metas: Metas(
                title: catalogSnapshot.data[index]['name'],
                artist: catalogSnapshot.data[index]['category'],
                image: MetasImage.asset('bliss-logo.png'))),
                showNotification: true
            );

          });
        },
      ),
    );
  }

  CATALOG_LIST(AsyncSnapshot catalogSnapshot){
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          Container(
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
          ),

          Container(
            height: MediaQuery.of(context).size.height - 180,
            child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) {
                  if(  catalogSnapshot.data[index]['type'].toString().toLowerCase().contains(searchController.text.toLowerCase())
                      || catalogSnapshot.data[index]['category'].toString().toLowerCase().contains(searchController.text.toLowerCase())
                      || catalogSnapshot.data[index]['name'].toString().toLowerCase().contains(searchController.text.toLowerCase())
                  ){
                    return SizedBox(height: 5.0);
                  }
                  return SizedBox.shrink();
                },
                padding: EdgeInsets.all(5.0),
                itemCount: catalogSnapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  if(  catalogSnapshot.data[index]['type'].toString().toLowerCase().contains(searchController.text.toLowerCase())
                      || catalogSnapshot.data[index]['category'].toString().toLowerCase().contains(searchController.text.toLowerCase())
                      || catalogSnapshot.data[index]['name'].toString().toLowerCase().contains(searchController.text.toLowerCase())
                  ){
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
                child: CATALOG_LIST(snapshot),
              ),
            );
          } else {
            return Container(color: Colors.black ,child: Center(child: Text('Something has gone wrong...', style: TextStyle(color: Colors.white, fontSize: 16.0))));
          }
        }
    );
  }
}