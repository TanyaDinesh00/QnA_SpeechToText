class Questions {
  int _questionNo = 0;
  List<String> _questionBank = [
    'Demo Question 1',
    'Demo Question 2',
    'Demo Question 3',
    'Demo Question 4',
  ];
  void nextQuestion() {
    if (_questionNo < _questionBank.length) {
      _questionNo++;
    } else {
      //isFinished();
    }
  }

  String getQuestionText() {
    return _questionBank[_questionNo];
  }

  bool isLast() {
    if (_questionNo == _questionBank.length - 1) {
      return true;
    } else {
      return false;
    }
  }

//  bool isFinished() {
//    if (_questionNo < _questionBank.length) {
//      return false;
//    } else {
//      return true;
//    }
//  }

  void reset() {
    _questionNo = 0;
  }
}
