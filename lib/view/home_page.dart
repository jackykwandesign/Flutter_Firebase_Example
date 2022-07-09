import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_1/auth_service.dart';
import 'package:firebase_flutter_1/config/firestoreConstant.dart';
import 'package:firebase_flutter_1/model/todoItem.model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AuthedPage extends StatefulWidget {
  AuthedPage({Key? key}) : super(key: key);

  @override
  State<AuthedPage> createState() => _AuthedPageState();
}

class _AuthedPageState extends State<AuthedPage> with TickerProviderStateMixin {
  late TabController _tabController;

  List<Widget> pages = [
    HomeTab(),
    TodoListTab(),
    ChatTab(),
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

class PersonalProfileTab extends StatelessWidget {
  PersonalProfileTab({Key? key}) : super(key: key);
  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            CircleAvatar(
              foregroundImage: NetworkImage(
                currentUser?.photoURL ?? '',
                scale: 5.0,
              ),
              backgroundImage: const AssetImage('assets/images/user_icon.jpg'),
            ),
            Text(currentUser?.displayName ?? "User"),
            Text(currentUser!.email ?? "Email"),
            ElevatedButton(
              onPressed: () {
                AuthService().signOut();
              },
              child: const Text('SignOut'),
            )
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: [
          const Text('Home Page'),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return const OtherFullPage();
                }));
              },
              child: const Text('Click me'))
        ],
      ),
    );
  }
}

class ChatTab extends StatefulWidget {
  ChatTab({Key? key}) : super(key: key);

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: const Text('Chat Tab'),
    );
  }
}

class OtherFullPage extends StatelessWidget {
  const OtherFullPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: const Text('asdsadsa'),
      ),
    );
  }
}

class TodoListTab extends StatefulWidget {
  const TodoListTab({Key? key}) : super(key: key);

  @override
  State<TodoListTab> createState() => _TodoListTabState();
}

class _TodoListTabState extends State<TodoListTab>
    with AutomaticKeepAliveClientMixin {
  final db = FirebaseFirestore.instance;
  List<TodoItem> todoList = [];
  bool isInitFirestoreListener = false;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if (!isInitFirestoreListener) {
      firestoreListenerInit();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: RefreshIndicator(
                onRefresh: () => getTodoList(),
                child: ListView.separated(
                  itemCount: todoList.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(
                    color: Colors.grey,
                    height: 1,
                  ),
                  itemBuilder: (_, int index) {
                    TodoItem todoItem = todoList[index];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPress: () =>
                          _displayTodoItemDetailDialog(context, todoItem),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(todoItem.name),
                          const Spacer(),
                          Checkbox(
                            value: todoItem.isFinished,
                            onChanged: (bool? newValue) {
                              todoItem.isFinished = newValue!;
                              updateTodoItem(todoItem.id, todoItem);
                            },
                          ),
                          IconButton(
                            onPressed: () {
                              _displayUpdateTodoItemDialog(context, todoItem);
                            },
                            icon: const Icon(
                              Icons.edit,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _displayDeleteTodoItemDialog(context, todoItem);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // await createToDoList();
          await _displayCreateTodoItemDialog(context);
          debugPrint('close dialog');
        },
      ),
    );
  }

  Future<void> _displayCreateTodoItemDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        late TextEditingController nameController = TextEditingController();
        bool isLoading = false;
        return StatefulBuilder(builder: (context, setState) {
          Future onSubmit() async {
            setState(() {
              isLoading = true;
            });
            await createToDoList(TodoItem(name: nameController.text));
            // await getTodoList();
            if (!mounted) {
              return;
            }
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context);
          }

          return AlertDialog(
            title: const Text('Create a todo item'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(label: Text('name')),
            ),
            actions: <Widget>[
              OutlinedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                child: const Text('Add'),
              ),
              isLoading ? const CircularProgressIndicator() : const SizedBox(),
            ],
          );
        });
      },
    );
  }

  Future<void> _displayUpdateTodoItemDialog(
      BuildContext context, TodoItem todoItem) async {
    return showDialog(
      context: context,
      builder: (context) {
        late TextEditingController nameController =
            TextEditingController(text: todoItem.name);
        bool isLoading = false;
        return StatefulBuilder(builder: (context, setState) {
          Future onSubmit() async {
            setState(() {
              isLoading = true;
            });
            todoItem.name = nameController.text;
            await updateTodoItem(todoItem.id, todoItem);
            // await getTodoList();
            if (!mounted) {
              return;
            }
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context);
          }

          return AlertDialog(
            title: const Text('Update todo item'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(label: Text('name')),
            ),
            actions: <Widget>[
              OutlinedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                child: const Text('Update'),
              ),
              isLoading ? const CircularProgressIndicator() : const SizedBox(),
            ],
          );
        });
      },
    );
  }

  Future<void> _displayTodoItemDetailDialog(
      BuildContext context, TodoItem todoItem) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Id: ${todoItem.id}'),
              const SizedBox(
                height: 5,
              ),
              Text('Name: ${todoItem.name}'),
              const SizedBox(
                height: 5,
              ),
              Text('CreateAt: ${dateFormat.format(todoItem.createAt)}'),
              const SizedBox(
                height: 5,
              ),
              Text('UpdateAt: ${dateFormat.format(todoItem.updateAt)}'),
            ],
          ),
        );
      },
    );
  }

  Future<void> _displayDeleteTodoItemDialog(
      BuildContext context, TodoItem todoItem) async {
    return showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false;
        return StatefulBuilder(builder: (context, setState) {
          Future onSubmit() async {
            setState(() {
              isLoading = true;
            });
            await deleteTodoItem(todoItem.id);
            if (!mounted) {
              return;
            }
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context);
          }

          return AlertDialog(
            title: Text('Do you want to delete todo item: ${todoItem.name} ?'),
            actions: <Widget>[
              OutlinedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                onPressed: isLoading ? null : onSubmit,
                child: const Text('Delete'),
              ),
              isLoading ? const CircularProgressIndicator() : const SizedBox(),
            ],
          );
        });
      },
    );
  }

  Future getTodoList() async {
    final result = await db.collection(FC.todoList.value).get();
    debugPrint('getTodoList: ${result.docs.length.toString()}');
    List<TodoItem> newTodoList = [];
    for (var element in result.docs) {
      newTodoList.add(TodoItem.fromJson({...element.data(), "id": element.id}));
    }
    setState(() {
      todoList = newTodoList;
    });
  }

  Future createToDoList(TodoItem newItem) async {
    await db.collection(FC.todoList.value).add(newItem.toJson());
  }

  Future updateTodoItem(String id, TodoItem newTodoItem) async {
    await db.collection(FC.todoList.value).doc(id).update(newTodoItem.toJson());
  }

  Future deleteTodoItem(String id) async {
    await db.collection(FC.todoList.value).doc(id).delete();
  }

  // subscribe to firestore
  firestoreListenerInit() {
    debugPrint('Init firestore listener');
    db.collection(FC.todoList.value).snapshots().listen((event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            setState(() {
              todoList.add(TodoItem.fromJson(
                  {...?change.doc.data(), "id": change.doc.id}));
            });
            debugPrint("New TodoItem: ${change.doc.data()}");
            break;
          case DocumentChangeType.modified:
            int foundIndex =
                todoList.indexWhere((element) => element.id == change.doc.id);
            if (foundIndex != -1) {
              setState(() {
                todoList[foundIndex] = TodoItem.fromJson(
                    {...?change.doc.data(), "id": change.doc.id});
              });
            }
            debugPrint("Modified TodoItem: ${change.doc.data()}");
            break;
          case DocumentChangeType.removed:
            int foundIndex =
                todoList.indexWhere((element) => element.id == change.doc.id);
            if (foundIndex != -1) {
              setState(() {
                todoList.removeAt(foundIndex);
              });
            }
            debugPrint("Removed TodoItem: ${change.doc.data()}");
            break;
        }
      }
    });

    setState(() {
      isInitFirestoreListener = true;
    });
  }
}
