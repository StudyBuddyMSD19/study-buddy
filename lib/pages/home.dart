import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'tasks.dart';
import 'scoreboard.dart';
import 'feed.dart';
import 'groups.dart';

User? loggedInUser;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _auth = FirebaseAuth.instance;

  final _authListener =
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      if (kDebugMode) {
        print('User is signed out!');
      }
    } else {
      if (kDebugMode) {
        print('User is signed in!');
      }
    }
  });

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;

        if (kDebugMode) {
          print('$user logged in');
        }
      }
    } catch (e) {
      print(e);
    }
  }

  /* Bottom navigation bar */
  int _currentIndex = 0;
  final List _screens = [
    const TasksPage(),
    const GroupPage(),
    const ScoreboardPage(),
    const FeedPage()
  ];
  bool isLoggedIn = false;
  bool isRegistered = false;

  void _updateIndex(int value) {
    setState(() {
      _currentIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _updateIndex,
        selectedItemColor: Colors.amber,
        selectedFontSize: 13,
        unselectedFontSize: 13,
        iconSize: 22,
        items: const [
          BottomNavigationBarItem(
            label: 'Tasks',
            icon: Icon(Icons.checklist),
          ),
          BottomNavigationBarItem(
            label: 'Groups',
            icon: Icon(Icons.people_alt_rounded),
          ),
          BottomNavigationBarItem(
            label: 'Scoreboard',
            icon: Icon(Icons.leaderboard),
          ),
          BottomNavigationBarItem(
            label: 'Feed',
            icon: Icon(Icons.feed),
          ),
        ],
      ),
    );
  }
}
