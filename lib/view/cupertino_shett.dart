


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoSheet extends StatelessWidget {
  const CupertinoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return  Center(


      child: CupertinoButton(
        color: Colors.orange,
          child: const Text("CupertinoSheet"), onPressed: () {

          showCupertinoModalPopup(context: context, builder: buildActionSheet);

          },),
    );
  }


  Widget buildActionSheet(BuildContext context)=>CupertinoActionSheet(
    title: const Text("CupertionSheet"),
    message: Text("CupertionSheet is a best"),
    actions: [

     CupertinoActionSheetAction(
         isDefaultAction: true,

         onPressed: () {

     }, child: const Text("Action 1")),



      CupertinoActionSheetAction(
        isDefaultAction: true,
          onPressed: () {

      }, child: const Text("Edit")),



      CupertinoActionSheetAction(
        isDestructiveAction: true,
          onPressed: () {

      }, child: const Text("Delete"))
    ],

    cancelButton: CupertinoActionSheetAction
      (

      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },

    ),


  );
}



