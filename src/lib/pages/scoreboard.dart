import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:study_buddy/pages/settings.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({Key? key}) : super(key: key);

  @override
  _ScoreboardPageState createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  final title = 'Scoreboard';

  /* Get all users and rank by score */
  final Stream<QuerySnapshot> _scoreboardStream = FirebaseFirestore.instance
      .collection('users')
      .orderBy('score', descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder(
        stream: _scoreboardStream,
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
                      leading: const Icon(
                        Icons.emoji_events,
                        size: 25.0,
                      ),
                      title: Text(
                        data['username'],
                      ),
                      subtitle: Text('${data['status']}'),
                      trailing: Text('${data['score']} XP'),
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
