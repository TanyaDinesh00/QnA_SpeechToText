import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Q n A',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SpeechToText _speech;
  bool _isListening = false;
  bool _speechRecognitionAvailable = false;
  String _oldRecognizedText = ' ';
  String _recognizedText = ' ';
  String selectedLang;
  TextEditingController inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    activateSpeechRecognizer();
  }

  Future<void> activateSpeechRecognizer() async {
    print('Initiate Speech Recognizer');
    _speech = SpeechToText();
//    _speech.statusListener(() {});
    _speechRecognitionAvailable = await _speech.initialize(
        onError: errorHandler, onStatus: onSpeechAvailability);
    var currentLocale = await _speech.systemLocale();
    if (null != currentLocale) {
      selectedLang = currentLocale.localeId;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report complaint'),
      ),
      body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.grey.shade200,
//                        child: Text(_oldRecognizedText + _recognizedText),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      controller: inputController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Type or Speak',
                      ),
//                      onEditingComplete: (){},
                    ),
                  ),
                ),
//                _buildButton(
//                  onPressed: _speechRecognitionAvailable && !_isListening
//                      ? () => start()
//                      : null,
//                  label:
//                      _isListening ? 'Listening...' : 'Listen ($selectedLang)',
//                ),
////                  _buildButton(
////                    onPressed: _isListening ? () => cancel() : null,
////                    label: 'Cancel',
////                  ),
//                _buildButton(
//                  onPressed: _isListening ? () => stop() : null,
//                  label: 'Stop',
//                ),
                !_isListening
                    ? _buildButton(
                        onPressed: _speechRecognitionAvailable && !_isListening
                            ? () => start()
                            : null,
                        label: _isListening
                            ? 'Listening...'
                            : 'Speak ($selectedLang)',
                      )
                    : _buildButton(
                        onPressed: _isListening ? () => stop() : null,
                        label: 'Stop',
                      ),
//                _buildButton(
//                  onPressed: () {
//                    print('Speech Recognition Available?' +
//                        _speechRecognitionAvailable.toString());
//                  },
//                  label: 'Speech Recognition Available?',
//                ),
              ],
            ),
          )),
    );
  }

  Widget _buildButton({String label, VoidCallback onPressed}) {
    return Padding(
        padding: EdgeInsets.all(12.0),
        child: RaisedButton(
          color: Colors.cyan.shade600,
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ));
  }

  void onRecognitionResult(SpeechRecognitionResult result) {
    setState(() => _recognizedText = result.recognizedWords);
    if (result.finalResult) {
      print('Recognition Stopped');
      setState(() {
        _oldRecognizedText += _recognizedText;
        _oldRecognizedText += ' ';
        _recognizedText = '';
        print(_oldRecognizedText + '===>' + _recognizedText);
      });
    }
    inputController.value = TextEditingValue(
      text: _oldRecognizedText + _recognizedText,
      selection: TextSelection.fromPosition(
        TextPosition(offset: (_oldRecognizedText + _recognizedText).length),
      ),
    );
  }

  void onSpeechAvailability(String status) {
    setState(() {
      _speechRecognitionAvailable = _speech.isAvailable;
      _isListening = _speech.isListening;
    });
//    print('Status Changed : ' + status);
//    if (status == 'notListening') {
//      print('Recognition Stopped');
//      setState(() {
//        _oldRecognizedText += _recognizedText;
//        _recognizedText = '';
//        print(_oldRecognizedText + '===>' + _recognizedText);
//      });
//    }
  }

  void errorHandler(SpeechRecognitionError error) {
    print(error.errorMsg);
    stop();
  }

  void start() {
    _oldRecognizedText = inputController.text;
    _speech.listen(
        onResult: onRecognitionResult,
        localeId: selectedLang,
        pauseFor: Duration(seconds: 5),
        listenFor: Duration(seconds: 30));
  }

  void cancel() {
    _speech.cancel();
    setState(() => _isListening = false);
  }

  void stop() {
    _speech.stop();
    setState(() => _isListening = false);
  }
}
