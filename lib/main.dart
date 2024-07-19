import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_widgets/view/bottom_bar.dart';
import 'package:ios_widgets/view/cupertino_context_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(


      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,

      home: BottomBarNavigation(),
      // home: CupertinContextMenus(),
    );
  }
}


