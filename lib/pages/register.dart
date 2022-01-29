import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  final String title = 'Registration';

  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool? _success;
  String _userEmail = '';
  String _username = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                validator: (String? value) {
                  if (value!.trim().isEmpty) {
                    return 'Please enter a username';
                  } else if (value.length < 3) {
                    return 'Username must be at least 3 characters';
                  } else if (value.length > 200) {
                    return 'Password must be shorter than 200 characters';
                  }
                  _username = value;
                },
              ),
              const Padding(padding: EdgeInsets.only(top: 10.0)),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  } else if (!value.contains(RegExp(r'\w+@\w+\.\w+'))) {
                    return 'Email must be a valid address';
                  } else if (value.length > 200) {
                    return 'Password must be shorter than 200 characters';
                  }
                },
              ),
              const Padding(padding: EdgeInsets.only(top: 10.0)),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  } else if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  } else if (value.length > 200) {
                    return 'Password must be shorter than 200 characters';
                  }
                  _password = value;
                },
              ),
              const Padding(padding: EdgeInsets.only(top: 10.0)),
              TextFormField(
                controller: _password2Controller,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Repeat password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please repeat your password';
                  } else if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  } else if (value.length > 200) {
                    return 'Password must be shorter than 200 characters';
                  } else if (value != _password) {
                    return 'Passwords do not match';
                  }
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _register();

                      addUser(_username, _userEmail);
                      addCollections();
                    }
                  },
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  child: const Text('CREATE ACCOUNT'),
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 20.0)),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const LoginPage();
                  }));
                },
                style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                child: const Text('I already have an account'),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  _success == null
                      ? ''
                      : (_success!
                          ? 'Successfully registered!'
                          : 'Registration failed'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /* Register user with username, email, password */
  Future<void> _register() async {
    try {
      final User? user = (await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ))
          .user;
      user?.updateDisplayName(
          _username); // explicitly set account name to chosen username

      if (user != null) {
        setState(() {
          _success = true;
          _userEmail = user.email ?? '';

          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const Home();
          }));
        });
      } else {
        _success = false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The provided password is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('Account with that email already exists');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  final String username = '';
  final String email = '';
  final int score = 5;
  final String status = 'Hi! I just joined~';
  final String groups = '';

  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  CollectionReference groupsCollection =
      FirebaseFirestore.instance.collection('groups');

  /* Create user in firestore DB, create feed, add to group */
  Future<void> addUser(username, email) {
    return usersCollection
        .doc(_auth.currentUser?.uid)
        .set({
          'username': username,
          'email': email,
          'score': score,
          'status': status,
        })
        .then((value) => print('User added'))
        .catchError((error) => print('Failed to add user: $error'));
  }

  /* Add user feed, first task, add to 'everyone' group */
  Future<void> addCollections() async {
    usersCollection
        .doc(_auth.currentUser?.uid)
        .collection('feed')
        .doc()
        .set({
          'exp_earned': score,
          'task_id': 0,
          'task_title': 'Welcome!',
          'time_done': Timestamp.now(),
        })
        .then((value) => print('Create Feed entry'))
        .catchError((error) => print('Failed to create feed entry: $error'));

    usersCollection
        .doc(_auth.currentUser?.uid)
        .collection('tasks')
        .doc()
        .set({
          'title': 'My first task',
          'description': 'Let\'s start working!',
          'completed': false,
          'effort': 'easy',
          'time_created': Timestamp.now(),
          'time_done': null
        })
        .then((value) => print('Add first task'))
        .catchError((error) => print('Failed to add first task: $error'));

    usersCollection
        .doc(_auth.currentUser?.uid)
        .collection('groups')
        .doc()
        .set({
          'name': 'everyone',
        })
        .then((value) => print('Join everyone group'))
        .catchError((error) => print('Failed to join everyone group: $error'));

    groupsCollection
        .doc('FtVr0ygwLiILLku7aKj0') // 'everyone' document ID
        .update({
          'member_count': FieldValue.increment(1),
        })
        .then((value) => print('Increased group member count'))
        .catchError(
            (error) => print('Failed to increase group member count: $error'));

    groupsCollection
        .doc('FtVr0ygwLiILLku7aKj0') // 'everyone' document ID
        .collection('group_members')
        .add({
          'user_id': _auth.currentUser?.uid,
        })
        .then((value) => print('Joined group'))
        .catchError((error) => print('Failed to join group: $error'));
  }
}
