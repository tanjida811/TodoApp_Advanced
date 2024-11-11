import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:to_do_app/prsentation/screen/folder_detail_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      home: FolderDetailScreen(
        folderName: 'Personal Tasks',
        creationDate: '2024-11-06',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
