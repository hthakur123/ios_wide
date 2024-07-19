import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'cupertino_context_menu.dart';
import 'cupertino_shett.dart';

class BottomBarNavigation extends StatelessWidget {
  const BottomBarNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
              label: "Home",
              icon: Icon(
                CupertinoIcons.home,
              )),
          BottomNavigationBarItem(
              label: "Chat", icon: Icon(CupertinoIcons.chat_bubble)),
          BottomNavigationBarItem(
              label: "Profile", icon: Icon(CupertinoIcons.profile_circled)),
          BottomNavigationBarItem(
              label: "Search", icon: Icon(CupertinoIcons.search)),
          BottomNavigationBarItem(
              label: "Location", icon: Icon(CupertinoIcons.map))
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const CupertinoSheet();
          case 1:
            return const CupertinContextMenus();

          case 2:
            return NewPage(
              title: "Profile",
              buttonColor: CupertinoColors.destructiveRed,
            );

          case 3:
            return NewPage(
              title: "Search",
              buttonColor: CupertinoColors.activeBlue,
            );

          case 4:
          default:
            return const Text("Search");
        }
      },
    );
  }
}

class NewPage extends StatelessWidget {
  String? title;
  final Color? buttonColor;
  NewPage({super.key, this.title, this.buttonColor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title!),
            const SizedBox(
              height: 3,
            ),
            Center(
              child: CupertinoButton(
                minSize: 44, // Default min height
                color: buttonColor,
                child: const Text('Press Me'),
                onPressed: () {



                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
