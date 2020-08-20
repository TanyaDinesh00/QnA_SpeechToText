import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  ResultScreen({this.resultText});
  final resultText;
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String outputText = '';

  @override
  void initState() {
    super.initState();
    outputText = widget.resultText;
    print('\n\n\n New pageeee');
    print(widget.resultText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Results Page"),
      ),
      body: SingleChildScrollView(
        child: Text(
          outputText,
          style: TextStyle(fontSize: 25.0),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
