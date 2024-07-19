




import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinContextMenus extends StatelessWidget {
  const CupertinContextMenus({super.key});

  @override
  Widget build(BuildContext context) {
    return  CupertinoPageScaffold (
      navigationBar: const CupertinoNavigationBar(
        middle: Text("ios Context Menu"),
      ),
        child:
        Center(

          child: CupertinoContextMenu(


            actions: [
             CupertinoContextMenuAction(

                 onPressed: () {

               },
               trailingIcon: CupertinoIcons.person,
                 child: const Text("Action 1"),


             ),

              CupertinoContextMenuAction(
                onPressed: () {

                },
                trailingIcon: CupertinoIcons.home,
                child: const Text("Action 2"),


              ),
              CupertinoContextMenuAction(
                isDestructiveAction: true,
                isDefaultAction: false,

                onPressed: () {
                  Navigator.pop(context);
                },
                trailingIcon: Icons.search,
                child: const Text("Delete"),


              )

            ],
            child: Container(
              height: 200,
              width: 300,
              color: Colors.green,
            ),
          ),
        )


    );
  }
}
