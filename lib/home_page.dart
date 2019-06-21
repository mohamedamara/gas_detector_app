import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flare_flutter/flare_actor.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _gasStatus, _animationName;
  Color _appBarColor;
  DatabaseReference _gasStatusRef;
  StreamSubscription<Event> _gasStatusSubscription;
  DatabaseError _error;

  @override
  void initState() {
    super.initState();
    _gasStatusRef = FirebaseDatabase.instance.reference().child('gas_status');
    _gasStatusSubscription = _gasStatusRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        if (event.snapshot.value == 'no') {
          _appBarColor = Colors.green;
          _gasStatus = 'Tout va bien';
          _animationName = 'success';
        } else if (event.snapshot.value == 'yes') {
          _appBarColor = Colors.red;
          _gasStatus = 'Gaz détecté';
          _animationName = 'fail';
        }
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
        print(_error.message);
      });
    });
  }

  @override
  void dispose() {
    _gasStatusSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _appBarColor ?? Colors.green,
        title: Text('Gas Detector App'),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Positioned(
            top: size.height * 0.08,
            child: Container(
              width: size.width,
              alignment: Alignment.center,
              child: Text(
                _gasStatus ?? 'aucune valeur',
                style: TextStyle(
                  fontSize: 30,
                  color: _appBarColor,
                ),
              ),
            ),
          ),
          Center(
            child: FlareActor(
              'assets/TeddyFork.flr',
              alignment: Alignment.center,
              animation: _animationName ?? 'idle',
              fit: BoxFit.contain,
              callback: (string) {
                if (string == 'success') {
                  setState(() {
                    _animationName = 'idle';
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
