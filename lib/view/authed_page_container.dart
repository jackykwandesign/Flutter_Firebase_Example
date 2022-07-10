import 'package:firebase_flutter_1/view/chatroom_page.dart';
import 'package:firebase_flutter_1/view/home_page.dart';
import 'package:firebase_flutter_1/view/personal_profile_page.dart';
import 'package:firebase_flutter_1/view/todolist_page.dart';
import 'package:flutter/material.dart';

class AuthedPageContainer extends StatefulWidget {
  AuthedPageContainer({Key? key}) : super(key: key);

  @override
  State<AuthedPageContainer> createState() => _AuthedPageContainerState();
}

class _AuthedPageContainerState extends State<AuthedPageContainer>
    with TickerProviderStateMixin {
  late TabController _tabController;

  List<Widget> pages = [
    const HomeTab(),
    const TodoListTab(),
    ChatroomPage(),
    PersonalProfileTab()
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: 0,
      length: pages.length,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(
          () {}); // this is a must to update controller index in build page
      debugPrint('selected Index = ${_tabController.index}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Text(_tabController.index.toString()),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: pages,
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
        currentIndex: _tabController.index,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (int selectIndex) {
          _tabController.index = selectIndex;
        },
      ),
    );
  }
}
