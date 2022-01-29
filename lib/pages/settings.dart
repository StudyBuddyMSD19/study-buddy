import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'home.dart';
import 'login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final title = 'Settings';
  String _title = '';
  String _newStatus = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /* Fetch account data from current user */
  final Stream<QuerySnapshot> _settingsStream = FirebaseFirestore.instance
      .collection('/users')
      .where('username', isEqualTo: loggedInUser?.displayName)
      .snapshots();

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  /* Update user status */
  Future<void> updateUserStatus(_newStatus) {
    return users
        .doc(_auth.currentUser?.uid)
        .update({'status': _newStatus})
        .then((_) => print('Updated status'))
        .then((value) => Navigator.pop(context))
        .catchError((error) => print('Update status failed: $error'));
  }

  @override
  Widget build(BuildContext context) {
    final ButtonBarTheme editStatusDialog = ButtonBarTheme(
      data: const ButtonBarThemeData(alignment: MainAxisAlignment.center),
      child: AlertDialog(
        title: const Text('Edit Status'),
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
                  expands: false,
                  maxLength: 100,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text';
                    }
                    if (value.length >= 100) {
                      return 'Too many characters, use less than 250';
                    }
                    _newStatus = value;
                  },
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      iconSize: 35.0,
                      // color: Colors.red,
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
                            updateUserStatus(_newStatus);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    /* Logout dialog */
    final ButtonBarTheme logoutDialog = ButtonBarTheme(
      data: const ButtonBarThemeData(alignment: MainAxisAlignment.center),
      child: AlertDialog(
        title: const Text('Do you want to log out?'),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        scrollable: true,
        content: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(padding: EdgeInsets.only(top: 10.0)),
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
                            // logout method

                            _auth.signOut();

                            Navigator.pushAndRemoveUntil(context,
                                MaterialPageRoute(builder: (context) {
                              return const LoginPage();
                            }), (route) => false);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    /* Body */
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: StreamBuilder(
        stream: _settingsStream,
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

              return Column(
                children: [
                  TextFormField(
                    initialValue: data['status'],
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      hintText: 'What are you up to?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        showDialog<void>(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => editStatusDialog);
                      });
                    },
                    style:
                        ElevatedButton.styleFrom(shape: const StadiumBorder()),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('EDIT STATUS'),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  TextFormField(
                    initialValue: data['username'],
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  TextFormField(
                    initialValue: data['email'],
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Email address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        showDialog<void>(
                            barrierDismissible: true,
                            context: context,
                            builder: (context) => logoutDialog);
                      });
                    },
                    style:
                        ElevatedButton.styleFrom(shape: const StadiumBorder()),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('LOG OUT'),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 30.0),
                  ),
                  const Text('Score'),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  Text(
                    '${data['score']}',
                    style: const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
