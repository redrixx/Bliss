import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

final mainClient = SupabaseClient(
    'https://srivnnrbfwgahaejaeic.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyaXZubnJiZndnYWhhZWphZWljIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NDc1NjEzMDgsImV4cCI6MTk2MzEzNzMwOH0.wkphUMJcDNu5midB_2SBiBXSsugeT7-PX65l2xwyfOY'
);

var _deviceHeight;
var _deviceWidth;

var _file;

class upload extends StatefulWidget {
  _upload createState() => _upload();
}

class _upload extends State<upload> {
  Stream _mainStream = Stream.empty();
  TextEditingController typeController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController filenameController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _mainStream = mainClient.from('media-catalog').stream(['id']).execute();
  }

  @override
  void dispose(){
    super.dispose();
    typeController.dispose();
    categoryController.dispose();
    nameController.dispose();
    filenameController.dispose();
  }

  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Upload successful.'),
                Text('Thank you for your contributions.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  UPLOAD(AsyncSnapshot snapshot){
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: ListView(
            children: [
              Column(
                  children: [

                    // Type Box
                    Container(
                      margin: EdgeInsets.only(top: 5.0, bottom: 10.0),
                      height: 50,
                      child: TextField(
                        controller: typeController,
                        decoration: InputDecoration(
                            hintText: "Type",
                            prefixIcon: Icon(Icons.search),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25.0)))
                        ),
                      ),
                    ),

                    // Category Box
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      height: 50,
                      child: TextField(
                        controller: categoryController,
                        decoration: InputDecoration(
                            hintText: "Category",
                            prefixIcon: Icon(Icons.search),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25.0)))
                        ),
                      ),
                    ),

                    // Name Box
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      height: 50,
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                            hintText: "Name",
                            prefixIcon: Icon(Icons.search),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25.0)))
                        ),
                      ),
                    ),

                    // Filename Box
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      height: 50,
                      child: TextField(
                        controller: filenameController,
                        decoration: InputDecoration(
                            hintText: "Filename (must be unique)",
                            prefixIcon: Icon(Icons.search),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25.0)))
                        ),
                      ),
                    ),

                    // Choose File Button
                    Container(
                      padding: EdgeInsets.all(5.0),
                      alignment: Alignment.center,
                      height: _deviceHeight * 0.25,
                      child: GestureDetector(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.file_upload, size: _deviceHeight * 0.15, color: Colors.white),
                          ],
                        ),
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp3']);
                          if (result != null){
                            _file = File('${result.files.single.path}');
                          }
                        },
                      ),
                    ),

                    // Upload Button
                    TextButton(child: Text("UPLOAD TO BLISS"), onPressed: () async {
                      if(_file != null){
                        await mainClient.from('media-catalog').insert([{
                          'bucketid': '${filenameController.text}.mp3',
                          'type': typeController.text,
                          'category': categoryController.text,
                          'name': nameController.text
                        }]).execute();
                        await mainClient.storage.from('media-bucket').upload('${filenameController.text}.mp3', _file);
                        _showDialog();
                      }else{
                        print("No valid file selected.");
                      }
                    }),

                  ]
              )
            ]
        )
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
                child: UPLOAD(snapshot),
              ),
            );
          } else {
            return Container(color: Colors.black ,child: Center(child: Text('Something has gone wrong...', style: TextStyle(color: Colors.white, fontSize: 16.0))));
          }
        }
    );
  }
}