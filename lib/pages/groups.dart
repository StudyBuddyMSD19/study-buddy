import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:study_buddy/pages/settings.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class GroupPage extends StatefulWidget {
  const GroupPage({Key? key}) : super(key: key);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final title = 'Groups';

  final Stream<QuerySnapshot> _groupsStream =
      FirebaseFirestore.instance.collection('groups').snapshots();

  /* Get all groups logged-in user is part of */
  CollectionReference userGroups = FirebaseFirestore.instance
      .collection('users')
      .doc(_auth.currentUser?.uid)
      .collection('groups');

  CollectionReference groups = FirebaseFirestore.instance.collection('groups');

  /* User joins group */
  Future<void> joinGroup(id) {
    increaseMemberCount(id);

    return groups
        .doc(id)
        .collection('group_members')
        .add({
          'user_id': _auth.currentUser?.uid,
        })
        .then((value) => print('Joined group'))
        .catchError((error) => print('Failed to join group: $error'));
  }

  /* Increase member count for given group - if user joins group */
  Future<void> increaseMemberCount(id) {
    return groups
        .doc(id)
        .update({
          'member_count': FieldValue.increment(1),
        })
        .then((value) => print('Increased group member count'))
        .catchError(
            (error) => print('Failed to increase group member count: $error'));
  }

  /* Decrease member count for given group - if user leaves group */
  Future<void> decreaseMemberCount(id) {
    return groups
        .doc(id)
        .update({
          'member_count': FieldValue.increment(-1),
        })
        .then((value) => print('Decreased group member count'))
        .catchError(
            (error) => print('Failed to decrease group member count: $error'));
  }

  /* Remove user from given group in DB */
  Future<void> leaveGroup(id) {
    decreaseMemberCount(id);

    return groups
        .doc(id)
        .collection('group_members')
        .doc(_auth.currentUser?.uid)
        .delete()
        .then((value) => print('Left group'))
        .catchError((error) => print('Failed to leave group: $error'));
  }

  /* Check if user is part of group */
  isJoined(data, id) {
    groups
        .doc(id)
        .collection('group_members')
        .doc(_auth.currentUser?.uid)
        .get()
        .then((value) => print('is joined $value'))
        .catchError(
            (error) => print('Failed to determine joined state: $error'));

    return true;
  }

  bool _selected = false;
  var icon = Icons.person_add;
  var isSelected = false;

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
        stream: _groupsStream,
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

          /* display list of all groups */
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
                        Icons.people_alt_rounded,
                        size: 25.0,
                      ),
                      title: Text(
                        data['name'],
                      ),
                      subtitle: Text('${data['member_count']} members'),
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
