import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:study_buddy/pages/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

User? user;
final _auth = FirebaseAuth.instance;

class TasksPage extends StatefulWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final title = 'Tasks';

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  CollectionReference tasks = FirebaseFirestore.instance
      .collection('users')
      .doc(_auth.currentUser?.uid)
      .collection('tasks');

  CollectionReference feed = FirebaseFirestore.instance
      .collection('users')
      .doc(_auth.currentUser?.uid)
      .collection('feed');

  final Query unfinishedTasks = FirebaseFirestore.instance
      .collection('users')
      .doc(_auth.currentUser?.uid)
      .collection('tasks');

  late final Stream<QuerySnapshot> _tasksStream;

  @override
  initState() {
    super.initState();
    _tasksStream = unfinishedTasks
        .orderBy('time_created',
            descending: false) // sort by date, old tasks on top
        .snapshots();
  }

  var checked = false;
  String _title = '';
  String _description = '';
  String _effort = 'easy';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  getEffortValue(String effort) {
    switch (effort) {
      case 'easy':
        return 5;
      case 'medium':
        return 10;
      case 'hard':
        return 20;
    }
  }

  bool _selectedEasy = false;
  bool _selectedMedium = false;
  bool _selectedHard = false;

  Future<void> addTask(title, description, effort) {
    return tasks
        .add({
          'title': title,
          'description': description,
          'completed': false,
          'effort': effort,
          'time_created': Timestamp.now(),
          'time_done': null
        })
        .then((value) => print('Task added'))
        .then((value) => Navigator.pop(context))
        .catchError((error) => print('Failed to add task: $error'));
  }

  Future<void> getTaskTitle(id) {
    return tasks
        .doc(id)
        .get()
        .then((value) => print('Got task $value'))
        .catchError((error) => print('Failed to get task: $error'));
  }

  var allData;

  Future<void> finishTask(id) async {
    await getData(id);

    var taskTitle = allData['title'];
    var effort = allData['effort'];

    var points = getEffortValue(effort);

    completeTask(id);
    addFeedEntry(id, points, taskTitle);
    updateScore(points);
  }

  Future<void> completeTask(id) {
    return tasks
        .doc(id)
        .update({'completed': true, 'time_done': Timestamp.now()})
        .then((value) => print('Task completed'))
        .catchError((error) => print('Failed to complete task: $error'));
  }

  Future<void> addFeedEntry(id, points, taskTitle) {
    return feed
        .add({
          'exp_earned': FieldValue.increment(points),
          'task_id': id,
          'task_title': taskTitle,
          'time_done': Timestamp.now(),
        })
        .then((value) => print('Feed added'))
        .catchError((error) => print('Failed to add feed: $error'));
  }

  Future<void> updateScore(points) {
    return users
        .doc(_auth.currentUser?.uid)
        .update({'score': FieldValue.increment(points)})
        .then((value) => print('Score updated'))
        .catchError((error) => print('Failed to update score: $error'));
  }

  Future<void> updateTask(id) {
    return tasks
        .doc(id)
        .update({
          'title': _title,
          'description': _description,
          'effort': _effort,
        })
        .then((value) => print('Task updated'))
        .then((value) => Navigator.pop(context))
        .catchError((error) => print('Failed to update task: $error'));
  }

  Future<void> deleteTask(id) {
    return tasks
        .doc(id)
        .delete()
        .then((value) => print('Task deleted'))
        .then((value) => Navigator.pop(context))
        .catchError((error) => print('Failed to delete task: $error'));
  }

  var editData;

  Future<Object?> getData(id) async {
    DocumentSnapshot<Object?> querySnapshot = await tasks.doc(id).get();

    allData = querySnapshot;

    var allDataSt = querySnapshot.data().toString();

    print(allDataSt);
  }

  @override
  Widget build(BuildContext context) {
    ButtonBarTheme addDialog = ButtonBarTheme(
      data: const ButtonBarThemeData(alignment: MainAxisAlignment.center),
      child: AlertDialog(
        title: const Text('Add task'),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        scrollable: true,
        content: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                width: MediaQuery.of(context).size.width * 0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(padding: EdgeInsets.only(top: 10.0)),
                TextFormField(
                  initialValue: null,
                  autocorrect: false,
                  maxLength: 150,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text';
                    }
                    if (value.length > 150) {
                      return 'Too many characters, use less than 150';
                    }
                    _title = value;
                  },
                ),
                const Padding(padding: EdgeInsets.only(top: 10.0)),
                TextFormField(
                  initialValue: '',
                  autocorrect: false,
                  maxLength: 250,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value!.length > 250) {
                      return 'Too many characters, use less than 250';
                    }
                    _description = value;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    children: [
                      const Text('Effort to complete'),
                      const Padding(padding: EdgeInsets.only(top: 10.0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text('easy'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            selectedShadowColor: Colors.amber,
                            selectedColor: Colors.amber,
                            backgroundColor: Colors.amber,
                            labelStyle: const TextStyle(color: Colors.black),
                            selected: _selectedEasy,
                            onSelected: (bool value) {
                              setState(() {
                                _effort = 'easy';
                                _selectedEasy = !_selectedEasy;
                                _selectedMedium = false;
                                _selectedHard = false;
                              });
                            },
                          ),
                          const Padding(padding: EdgeInsets.only(right: 10.0)),
                          ChoiceChip(
                            label: const Text('medium'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            selectedShadowColor: Colors.amber,
                            selectedColor: Colors.amber,
                            backgroundColor: Colors.amber,
                            labelStyle: const TextStyle(color: Colors.black),
                            selected: _selectedMedium,
                            onSelected: (bool value) {
                              setState(() {
                                _effort = 'medium';
                                _selectedMedium = !_selectedMedium;
                                _selectedEasy = false;
                                _selectedHard = false;
                              });
                            },
                          ),
                          const Padding(padding: EdgeInsets.only(right: 10.0)),
                          ChoiceChip(
                            label: const Text('hard'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            selectedShadowColor: Colors.amber,
                            selectedColor: Colors.amber,
                            backgroundColor: Colors.amber,
                            labelStyle: const TextStyle(color: Colors.black),
                            selected: _selectedHard,
                            onSelected: (bool value) {
                              setState(() {
                                _effort = 'hard';
                                _selectedHard = !_selectedHard;
                                _selectedEasy = false;
                                _selectedMedium = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.clear),
                iconSize: 35.0,
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.check),
                iconSize: 35.0,
                color: Colors.green,
                onPressed: () {
                  setState(() {
                    if (_formKey.currentState!.validate()) {
                      addTask(_title, _description, _effort);
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );

    var _editDialogId = '';

    ButtonBarTheme editDialog = ButtonBarTheme(
      data: const ButtonBarThemeData(alignment: MainAxisAlignment.center),
      child: AlertDialog(
        title: const Text('Edit task'),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        scrollable: true,
        actions: [
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.clear),
                iconSize: 35.0,
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.check),
                iconSize: 35.0,
                color: Colors.green,
                onPressed: () {
                  setState(() {
                    if (_formKey.currentState!.validate()) {
                      updateTask(_editDialogId);
                      _description = '';
                      _title = '';
                      _effort = '';
                    }
                  });
                },
              ),
            ],
          ),
        ],
        content: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                width: MediaQuery.of(context).size.width * 0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(padding: EdgeInsets.only(top: 10.0)),
                TextFormField(
                  initialValue: _title,
                  autocorrect: false,
                  expands: false,
                  maxLength: 150,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text';
                    }
                    if (value.length > 150) {
                      return 'Too many characters, use less than 150';
                    }

                    _title = value.trim();
                  },
                ),
                const Padding(padding: EdgeInsets.only(top: 10.0)),
                TextFormField(
                  initialValue: _description,
                  autocorrect: false,
                  maxLength: 250,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value!.length > 250) {
                      return 'Too many characters, use less than 250';
                    }
                    _description = value.trim();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    children: [
                      const Text('Effort to complete'),
                      const Padding(padding: EdgeInsets.only(top: 10.0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text('easy'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            selectedShadowColor: Colors.amber,
                            selectedColor: Colors.amber,
                            backgroundColor: Colors.amber,
                            labelStyle: const TextStyle(color: Colors.black),
                            selected: _selectedEasy,
                            onSelected: (bool value) {
                              setState(() {
                                _effort = 'easy';
                                _selectedEasy = !_selectedEasy;
                                _selectedMedium = false;
                                _selectedHard = false;
                              });
                            },
                          ),
                          const Padding(padding: EdgeInsets.only(right: 10.0)),
                          ChoiceChip(
                            label: const Text('medium'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            selectedShadowColor: Colors.amber,
                            selectedColor: Colors.amber,
                            backgroundColor: Colors.amber,
                            labelStyle: const TextStyle(color: Colors.black),
                            selected: _selectedMedium,
                            onSelected: (bool value) {
                              setState(() {
                                _effort = 'medium';
                                _selectedMedium = !_selectedMedium;
                                _selectedEasy = false;
                                _selectedHard = false;
                              });
                            },
                          ),
                          const Padding(padding: EdgeInsets.only(right: 10.0)),
                          ChoiceChip(
                            label: const Text('hard'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            selectedShadowColor: Colors.amber,
                            selectedColor: Colors.amber,
                            backgroundColor: Colors.amber,
                            labelStyle: const TextStyle(color: Colors.black),
                            selected: _selectedHard,
                            onSelected: (bool value) {
                              setState(() {
                                _effort = 'hard';
                                _selectedHard = !_selectedHard;
                                _selectedEasy = false;
                                _selectedMedium = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                        onPressed: () {
                          setState(() {
                            deleteTask(_editDialogId);
                          });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red[800],
                        ),
                        label: Text(
                          'DELETE',
                          style: TextStyle(color: Colors.red[800]),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.settings,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        onPressed: () {
          showDialog<void>(
              barrierDismissible: false,
              context: context,
              builder: (context) => addDialog);
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: _tasksStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasError) {
            return const Text('Something went wrong, please retry');
          }
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SpinKitDualRing(
                  color: Colors.white30,
                  size: 50.0,
                ),
                Padding(padding: EdgeInsets.only(top: 10.0)),
                Text(
                  'Loading',
                  style: TextStyle(color: Colors.white30),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(15),
            children:
                streamSnapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              return Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Checkbox(
                        onChanged: (bool? value) {
                          if (value == true) {
                            finishTask(document.id);

                            setState(() {
                              checked = value!;
                            });
                          }
                        },
                        value: data['completed'],
                        activeColor: Colors.amber,
                      ),
                      title: Wrap(
                        children: [
                          Text('${data['title']}  '),
                          Chip(
                            labelPadding:
                                const EdgeInsets.symmetric(vertical: -3.5),
                            label: Text(
                              '${data['effort']}',
                              style: const TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Colors.amber,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        '${data['description']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editDialogId = document.id;

                          getData(_editDialogId);

                          setState(() {
                            showDialog<void>(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) => editDialog);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
