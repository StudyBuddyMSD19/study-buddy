import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:study_buddy/pages/home.dart';
import 'package:study_buddy/pages/login.dart';
import 'firebase_config.dart';
import 'package:study_buddy/pages/error.dart';
import 'package:study_buddy/pages/loading.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseConfig.platformOptions);
  await FirebaseFirestore.instance.enablePersistence();
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  runApp(const StudyBuddy());
}

class StudyBuddy extends StatelessWidget {
  const StudyBuddy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyBuddy',
      theme: ThemeData(
        /* light themes */
        brightness: Brightness.light,
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
        ),
      ),
      highContrastTheme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      /* dark themes */
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      highContrastDarkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      /* follow system theme */
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: App(),
      ),
    );
  }
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const ErrorPage();
        }

        if (snapshot.connectionState == ConnectionState.done) {
          if (_auth.currentUser != null) {
            return const Home();
          } else {
            return const LoginPage();
          }
        }
        return const LoadingPage();
      },
    );
  }
}
