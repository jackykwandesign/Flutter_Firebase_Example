import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_me/firebase_utils/firestore_constant.dart';
import 'package:chat_me/firebase_utils/firestore_listener.dart';
import 'package:chat_me/model/todoItem.model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoListTab extends StatefulWidget {
  const TodoListTab({Key? key}) : super(key: key);

  @override
  State<TodoListTab> createState() => _TodoListTabState();
}

class _TodoListTabState extends State<TodoListTab>
    with AutomaticKeepAliveClientMixin {
  final db = FirebaseFirestore.instance;
  late CollectionReference<Map<String, dynamic>> todoListCollection;
  List<TodoItem> todoList = [];
  bool isInitFirestoreListener = false;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    todoListCollection = db
        .collection(FC.todoLists.value)
        .doc(currentUser!.uid)
        .collection(FC.todoLists.value);
    if (!isInitFirestoreListener) {
      firestoreListenerInit();
    }
    super.initState();
  }

  @override
  // ignore: must_call_super
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
            await createToDoList(
                TodoItem(name: nameController.text, userId: currentUser!.uid));
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
              Text('CreateAt: ${dateFormat.format(todoItem.createAt!)}'),
              const SizedBox(
                height: 5,
              ),
              Text('UpdateAt: ${dateFormat.format(todoItem.updateAt!)}'),
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
    final result = await todoListCollection.get();
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
    await todoListCollection.add(newItem.toJson());
  }

  Future updateTodoItem(String id, TodoItem newTodoItem) async {
    await todoListCollection.doc(id).update(newTodoItem.toJson());
  }

  Future deleteTodoItem(String id) async {
    await todoListCollection.doc(id).delete();
  }

  // subscribe to firestore
  firestoreListenerInit() {
    debugPrint('Init firestore listener');
    getFirestoreListener(
        todoListCollection.snapshots(), todoList, setState, TodoItem.fromJson);
    setState(() {
      isInitFirestoreListener = true;
    });
  }
}
