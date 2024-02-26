// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart'; // Import your page files

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;

  @override
  void initState() {
    super.initState();

    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _user != null
          ? Scaffold(
              body: HomePage(),
            )
          : Scaffold(
              body: _googleSignInButton(),
            ),
    );
  }

  Widget _googleSignInButton() {
    return Center(
        child: Container(
      height: 900, // Adjust the height as needed
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              'assets/images/Hero.jpg'), // Replace with your image asset
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 150,
              ),
              Padding(
                padding: EdgeInsets.only(top: 60.0), // Add padding to the top
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'AGRI',
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'FARM',
                      style: TextStyle(
                        color: Color.fromARGB(255, 24, 156, 19),
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30.0),
                child: Text(
                  'Empowering farmers with Modern Ecommerce Solution. \nExplore, Transact and Thrive in Agriculture. \nDiscover Quality tools, Accurate Prediction and Growing Community.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 50,
                child: SignInButton(
                  Buttons.google,
                  text: "Signup with Google",
                  onPressed: _handleGoogleSignIn,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget LandingPage() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: NetworkImage(_user!.photoURL!),
            )),
          ),
          Text(_user!.email!),
          Text(_user!.uid),
          MaterialButton(
              color: Colors.red,
              child: const Text("Sign Out"),
              onPressed: _auth.signOut)
        ],
      ),
    );
  }

  void _handleGoogleSignIn() async {
    try {
      GoogleAuthProvider _googleAuthProvider = GoogleAuthProvider();
      UserCredential userCredential =
          await _auth.signInWithProvider(_googleAuthProvider);

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (error) {
      print(error);
    }
  }
}
