import 'package:flutter/material.dart';

class TravelPage extends StatefulWidget {
  TravelPage({Key? key}) : super(key: key);

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> with TickerProviderStateMixin {
  late TabController tabController;
  int pageIndex = 0;
  List<Widget> list = [
    Tab(icon: Icon(Icons.card_travel)),
    Tab(icon: Icon(Icons.add_shopping_cart)),
  ];
  List<Widget> bodyList = [
    const Center(
      child: Text('1'),
    ),
    const Center(
      child: Text('2'),
    ),
  ];
  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: bodyList.length,
      vsync: this,
      initialIndex: 0,
    );
    tabController.addListener(() {
      setState(() {
        // pageIndex = tabController.index;
      });
      debugPrint('Selected Index: $pageIndex');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          tabs: list,
          controller: tabController,
        ),
      ),
      body: Column(
        children: [
          Text(tabController.index.toString()),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: bodyList,
            ),
          ),
        ],
      ),
    );
  }
}

// class TravelPage extends StatefulWidget {
//   @override
//   _TravelPageState createState() => _TravelPageState();
// }

// class _TravelPageState extends State<TravelPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _controller;
//   int _selectedIndex = 0;

//   List<Widget> list = [
//     Tab(icon: Icon(Icons.card_travel)),
//     Tab(icon: Icon(Icons.add_shopping_cart)),
//   ];

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // Create TabController for getting the index of current tab
//     _controller = TabController(length: list.length, vsync: this);

//     _controller.addListener(() {
//       setState(() {
//         _selectedIndex = _controller.index;
//       });
//       print("Selected Index: " + _controller.index.toString());
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           bottom: TabBar(
//             onTap: (index) {
//               // Should not used it as it only called when tab options are clicked,
//               // not when user swapped
//             },
//             controller: _controller,
//             tabs: list,
//           ),
//           title: Text('Tabs Demo'),
//         ),
//         body: TabBarView(
//           controller: _controller,
//           children: [
//             Center(
//                 child: Text(
//               _selectedIndex.toString(),
//               style: TextStyle(fontSize: 40),
//             )),
//             Center(
//                 child: Text(
//               _selectedIndex.toString(),
//               style: TextStyle(fontSize: 40),
//             )),
//           ],
//         ),
//       ),
//     );
//   }
// }
