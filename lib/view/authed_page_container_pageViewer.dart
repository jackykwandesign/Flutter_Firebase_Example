import 'package:firebase_flutter_1/view/chat_page.dart';
import 'package:firebase_flutter_1/view/home_page.dart';
import 'package:firebase_flutter_1/view/personal_profile_page.dart';
import 'package:firebase_flutter_1/view/todolist_page.dart';
import 'package:flutter/material.dart';

class AuthedPageContainerPageViewer extends StatefulWidget {
  AuthedPageContainerPageViewer({Key? key}) : super(key: key);

  @override
  State<AuthedPageContainerPageViewer> createState() =>
      _AuthedPageContainerPageViewerState();
}

class _AuthedPageContainerPageViewerState
    extends State<AuthedPageContainerPageViewer> {
  late PageController _pageController;
  int currentPageIndex = 0;

  List<Widget> pages = [
    const HomeTab(),
    const TodoListTab(),
    ChatroomPage(),
    PersonalProfileTab()
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentPageIndex);
    // _pageController.addListener(() {
    //   setState(
    //       () {}); // this is a must to update controller index in build page
    //   debugPrint('selected Index = ${_pageController.page}');
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Text(_tabController.index.toString()),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: pages,
              onPageChanged: (int newPageIndex) {
                setState(() {
                  currentPageIndex = newPageIndex;
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list,
            ),
            label: 'Todo',
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.chat,
              ),
              label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              label: 'Profile')
        ],
        currentIndex: currentPageIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (int selectIndex) {
          _pageController.animateToPage(
            selectIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          );
        },
      ),
    );
  }
}
