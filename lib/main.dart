import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:voice_assistant/login.dart';
import 'package:voice_assistant/secondPage.dart';

void main() {
  runApp(const MyApp());
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      navigatorObservers: [routeObserver],
      initialRoute: '/',
      routes: {
        '/second': (context) => const SecondPage(),
        '/login': (context) => const LoginScreen()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with RouteAware {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => setVisuals("first"));
  }

  void setVisuals(String screen) {
    var visual = "{\"screen\":\"$screen\"}";
    AlanVoice.setVisualState(visual);
  }

  _MyHomePageState() {
    /// Init Alan Button with project key from Alan Studio
    AlanVoice.addButton(
        "6326c7ef59dc89a9a91989d3cb62f90a2e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);

    /// Handle commands from Alan Studio
    AlanVoice.onCommand.add((command) => _handleCommand(command.data));
  }

  void _handleCommand(Map<String, dynamic> command) {
    switch (command['command']) {
      case "increment":
        _incrementCounter();
        break;
      case "forward":
        Navigator.pushNamed(context, '/second');
        break;
      case "back":
        Navigator.pop(context);
        break;
      case "deactivate":
        deactivateAlan();
        break;
      case "login":
        Navigator.pushNamed(context, '/login');
        break;
      default:
        Fluttertoast.showToast(
            msg: 'Unknown Command', backgroundColor: Colors.redAccent);
        break;
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    sendData();
  }

  void sendData() {
    var params = jsonEncode({"count": _counter});
    AlanVoice.callProjectApi("script::getCount", params);
  }

  void activateAlan() async {
    var isActivate = await AlanVoice.isActive();
    if (!isActivate) {
      AlanVoice.activate();
    }
  }

  void deactivateAlan() {
    AlanVoice.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.amberAccent[600],
            title: Text('Audio Books'),
            centerTitle: true),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$_counter",
              style: const TextStyle(fontSize: 45.0),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/second');
                },
                child: const Text('Open the second Page'))
          ],
        ))
        // body: Container(
        //   child: GestureDetector(
        //     onDoubleTap: () {
        //       activateAlan();
        //     },
        //   ),
        // ),
        );
  }
}
