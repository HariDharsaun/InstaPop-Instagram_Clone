import 'package:flutter/material.dart';
import 'package:instapop_/pages/homepage.dart';
import 'package:instapop_/pages/messagingpage.dart';
import 'package:instapop_/pages/newpostpage.dart';
import 'package:instapop_/pages/searchpage.dart';
import 'package:instapop_/pages/userprofilepage.dart';

class PageStack extends StatefulWidget {
  const PageStack({super.key});

  @override
  State<PageStack> createState() => _PageStackState();
}

class _PageStackState extends State<PageStack> {
  int currrentindex = 0;
  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        body: IndexedStack(
          index: currrentindex,
          children: [
            Homepage(),
            SearchPage(),
            Newpostpage(),
            MessagingPage(),
            Userprofilepage(),
          ],
        ),
      
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          currentIndex: currrentindex,
          onTap: (index)
          {
            setState(() {
              currrentindex = index;
            });
          },
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search),label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.add),label: 'Post'),
            BottomNavigationBarItem(icon: Icon(Icons.message_outlined),label: 'Message'),
            BottomNavigationBarItem(icon: Icon(Icons.person),label: 'Profile')
          ],
        ),
      ),
    );
  }
}