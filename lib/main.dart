import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reportqanda/questions.dart';
import 'package:reportqanda/result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  String _answers = '';
  String selectedLang;
  TextEditingController inputController = TextEditingController();

  Questions questions = Questions();

  @override
  void initState() {
    super.initState();
    activateSpeechRecognizer();
  }

  Future<void> activateSpeechRecognizer() async {
    print('Initiate Speech Recognizer');
    _speech = SpeechToText();
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
                  flex: 1,
                  child: Container(
                    child: Center(
                      child: Text(
                        questions.getQuestionText(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.grey.shade200,
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      controller: inputController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Type or Press Speak',
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    !_isListening
                        ? _buildButton(
                            onPressed:
                                _speechRecognitionAvailable && !_isListening
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
                    _buildButton(
                      onPressed: _submit,
                      label: 'Submit',
                    ),
                    _buildButton(
                      onPressed: _skip,
                      label: 'Skip',
                    ),
                  ],
                ),
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

  void _submit() {
    cancel();
    stop();
    _oldRecognizedText = inputController.text;
    setState(() {
      _answers += 'Question: ' +
          questions.getQuestionText() +
          '\nAnswer: ' +
          _oldRecognizedText +
          '\n\n';
      _oldRecognizedText = '';
      _recognizedText = '';
    });
    inputController.value = TextEditingValue(
      text: _oldRecognizedText + _recognizedText,
      selection: TextSelection.fromPosition(
        TextPosition(offset: (_oldRecognizedText + _recognizedText).length),
      ),
    );
    print(_answers);
    if (questions.isLast()) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ResultScreen(
          resultText: _answers,
        );
      })).then((value) {
        print("Back to previous Page!");
        reset();
      });
    } else {
      setState(() {
        questions.nextQuestion();
      });
    }
  }

  void _skip() {
    setState(() {
      _oldRecognizedText = '';
      _recognizedText = '';
      inputController.text = '';
    });
    if (questions.isLast()) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ResultScreen(
          resultText: _answers,
        );
      })).then((value) {
        print("Back to previous Page!");
        reset();
      });
    } else {
      setState(() {
        questions.nextQuestion();
      });
    }
  }

  void reset() {
    setState(() {
      questions.reset();
      _answers = _recognizedText = _oldRecognizedText = "";
    });
  }

  // [Speech recognition Functions are below this comment]

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
  }

  void errorHandler(SpeechRecognitionError error) {
    if (error.errorMsg != 'error_speech_timeout' &&
        error.errorMsg != 'error_no_match') {
      Alert(context: context, title: "Error", desc: error.toString()).show();
    }
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

  //Others

}
