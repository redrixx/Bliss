import 'dart:io';
import 'dart:math';
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
List<String> _typeSuggest = <String>[];
List<String> _categorySuggest = <String>[];

_blissInputDecoration(String _hint){
  return InputDecoration(
      hintText: _hint,
      prefixIcon: Icon(Icons.search),
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)))
  );
}

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
    _typeSuggest.clear();
    _categorySuggest.clear();
  }

  getAutoComplete(AsyncSnapshot snapshot){
    for(var entry in snapshot.data){
      _typeSuggest.add(entry['type']);
      _categorySuggest.add(entry['category']);
    }
    _typeSuggest = _typeSuggest.toSet().toList();
    _categorySuggest = _categorySuggest.toSet().toList();
  }

  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(
      Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)))
  );

  Future<void> _showDialog(String messageName, String firstLine, String secondLine) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(messageName),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(firstLine),
                Text(secondLine),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _filenameCheck(snapshot){
    bool returnVal = false;

    for(int index = 0; index < snapshot.data.length; index++){
      if(snapshot.data[index]['bucketid'].toString().toLowerCase().contains('${filenameController.text.toLowerCase()}.mp3')){
        returnVal = true;
      }
    }

    return returnVal;
  }

  UPLOAD(AsyncSnapshot snapshot){
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: ListView(
            children: [
              Column(
                  children: [

                    // Type Autocomplete Box
                    Container(
                        margin: EdgeInsets.only(bottom: 10.0),
                        height: 50,
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<String>.empty();
                            }
                            return _typeSuggest.where((String current) {
                              return current.toString().contains(textEditingValue.text);
                            });
                          },
                          fieldViewBuilder: (BuildContext context, TextEditingController typeController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                            return TextFormField(
                              controller: typeController,
                              decoration: _blissInputDecoration('Type'),
                              focusNode: focusNode,
                              onFieldSubmitted: (String value) {
                                onFieldSubmitted();
                                this.typeController.text = value;
                              },
                            );
                          },
                          onSelected: (String selection) {
                            typeController.text = selection;
                          },
                        )
                    ),

                    // Category Autocomplete Box
                    Container(
                        margin: EdgeInsets.only(bottom: 10.0),
                        height: 50,
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<String>.empty();
                            }
                            return _categorySuggest.where((String current) {
                              return current.toString().contains(textEditingValue.text);
                            });
                          },
                          fieldViewBuilder: (BuildContext context, TextEditingController categoryController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                            return TextFormField(
                              controller: categoryController,
                              decoration: _blissInputDecoration('Category'),
                              focusNode: focusNode,
                              onFieldSubmitted: (String value) {
                                onFieldSubmitted();
                                this.categoryController.text = value;
                              },
                            );
                          },
                          onSelected: (String selection) {
                            categoryController.text = selection;
                          },
                        )
                    ),

                    // Name Box
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      height: 50,
                      child: TextField(
                        controller: nameController,
                        decoration: _blissInputDecoration('Name'),
                      ),
                    ),

/*                    // Filename Box
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      height: 50,
                      child: TextField(
                        controller: filenameController,
                        decoration: _blissInputDecoration('Filename (must be unique)'),
                      ),
                    ),*/

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
                      filenameController.text = getRandomString(20);
                      if(typeController.text == '' || categoryController.text == '' || nameController.text == ''){
                        _showDialog('Unsuccessful.', 'Upload failed.', 'There is no information entered.');
                      }else if(filenameController.text.contains(' ') || _filenameCheck(snapshot)){
                        _showDialog('Unsuccessful.', 'Upload failed.', 'Invalid filename (it either already exists or has invalid characters).');
                      }else if(_file == null){
                        _showDialog('Unsuccessful.', 'Upload failed.', 'There is no valid file selected.');
                      }else{
                        await mainClient.from('media-catalog').insert([{
                          'bucketid': '${filenameController.text}.mp3',
                          'type': typeController.text,
                          'category': categoryController.text,
                          'name': nameController.text
                        }]).execute();
                        await mainClient.storage.from('media-bucket').upload('${filenameController.text}.mp3', _file);
                        _showDialog('Success!', 'Upload successful.', 'Thank you for your contributions.');
                        typeController.clear();
                        categoryController.clear();
                        nameController.clear();
                        filenameController.clear();
                        _file == null;
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
            getAutoComplete(snapshot);
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