import 'package:flutter/material.dart';
import 'package:instapop_/pages/addpost.dart';
import 'package:instapop_/pages/addreels.dart';

class Newpostpage extends StatefulWidget {
  const Newpostpage({super.key});

  @override
  State<Newpostpage> createState() => _NewpostpageState();
}

int currentIndex = 0;

class _NewpostpageState extends State<Newpostpage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView(
              onPageChanged: (index)
              {
                setState(() {
                  currentIndex = index;
                });
              },
              children: [
                AddPostPage(),
                AddReelsPage()
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              width: MediaQuery.of(context).size.width*0.25,
              height: MediaQuery.of(context).size.width*0.08,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(50)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Post",style: TextStyle(color: currentIndex == 0?  Colors.white : Colors.white30),),
                  SizedBox(width: 5,),
                  Text("Reels",style: TextStyle(color: currentIndex == 1 ?  Colors.white : Colors.white30))
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}