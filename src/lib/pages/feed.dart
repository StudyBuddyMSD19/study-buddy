import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy/pages/settings.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final title = 'Feed';

  /* Get all completed tasks */
  final Stream<QuerySnapshot> _feedStream = FirebaseFirestore.instance
      .collection('users')
      .doc(_auth.currentUser?.uid)
      .collection('feed')
      .orderBy('time_done', descending: true)
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _feedStream,
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
                        Icons.notifications,
                        size: 25.0,
                      ),
                      title: Row(
                        children: [
                          const Text('Received'),
                          Text(
                            ' ${data['exp_earned']} XP',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(' for "${data['task_title']}"'),
                        ],
                      ),
                      subtitle: Text(DateFormat('dd MMM yyyy @ HH:mm')
                          .format(data['time_done'].toDate())),
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
