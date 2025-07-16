import 'package:flutter/material.dart';
import 'package:instapop_/pages/homepage.dart';
import 'package:instapop_/pages/messagingpage.dart';
import 'package:instapop_/pages/newpostpage.dart';
import 'package:instapop_/pages/postview.dart';
import 'package:instapop_/pages/searchpage.dart';
import 'package:instapop_/pages/userprofilepage.dart';

class PageStack extends StatefulWidget {
  const PageStack({super.key});

  @override
  State<PageStack> createState() => _PageStackState();
}

class _PageStackState extends State<PageStack> {
  int currrentindex = 0;
  late PageController controller;

  @override
  void initState()
  {
    super.initState();
    controller = PageController();
  }

  @override
  void dispose(){
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: controller,
          onPageChanged: (index){
            setState(() {
              currrentindex = index;
            });
          },
          children: [
              HomePage(),
              SearchPage(),
              Newpostpage(),
              MessagingPage(),
              Userprofilepage(),
            ]
        ),
      
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          currentIndex: currrentindex,
          onTap: (index)
          {
            controller.jumpToPage(index);
          },
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home),label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search),label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.add),label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.message_outlined),label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person),label: '')
          ],
        ),
      ),
    );
  }
}