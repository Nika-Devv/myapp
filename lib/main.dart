import 'package:flutter/material.dart';
import 'package:myapp/list_view_insertion.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: const ListViewInsertion(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Display Section
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(
                display,
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w300, color: Colors.white),
              ),
            ),
          ),
          // Buttons Section
          Column(
            children: [
              Row(children: [
                buildButton('AC', Colors.grey, textColor: Colors.black),
                buildButton('+/-', Colors.grey, textColor: Colors.black),
                buildButton('%', Colors.grey, textColor: Colors.black),
                buildButton('÷', Colors.orange),
              ]),
              Row(children: [
                buildButton('7', Colors.white12),
                buildButton('8', Colors.white12),
                buildButton('9', Colors.white12),
                buildButton('×', Colors.orange),
              ]),
              Row(children: [
                buildButton('4', Colors.white12),
                buildButton('5', Colors.white12),
                buildButton('6', Colors.white12),
                buildButton('-', Colors.orange),
              ]),
              Row(children: [
                buildButton('1', Colors.white12),
                buildButton('2', Colors.white12),
                buildButton('3', Colors.white12),
                buildButton('+', Colors.orange),
              ]),
              Row(children: [
                buildButton('0', Colors.white12),
                buildButton('.', Colors.white12),
                buildButton('=', Colors.orange),
              ]),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
  String display = '0';

  Widget buildButton(String text, Color color, {Color textColor = Colors.white}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
            backgroundColor: color,
          ),
          onPressed: () {}, // Logic goes here
          child: Text(
            text,
            style: TextStyle(fontSize: 28, color: textColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
