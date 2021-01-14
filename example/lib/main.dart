import 'package:flutter/material.dart';
import 'dart:async';

import 'package:logger/logger.dart';
import 'package:logger_flutter/logger_flutter.dart';

class StreamOutput extends LogOutput {
  StreamController<OutputEvent> _controller;
  bool _shouldForward = false;

  StreamOutput() {
    _controller = StreamController<OutputEvent>.broadcast(
      onListen: () => _shouldForward = true,
      onCancel: () => _shouldForward = false,
    );
  }
  Stream<OutputEvent> get stream => _controller.stream;

  @override
  void output(OutputEvent event) {
    if (!_shouldForward) {
      return;
    }
    _controller.add(event);
  }

  @override
  void destroy() {
    _controller.close();
  }
}

void main() {
  runApp(MyApp());
  log();
}

var logOut = StreamOutput();
var logger = Logger(printer: PrettyPrinter(), output: logOut);
var loggerNoStack =
    Logger(printer: PrettyPrinter(methodCount: 0), output: logOut);

void log() {
  logger.d("Log message with 2 methods");
  loggerNoStack.i("Info message");
  loggerNoStack.w("Just a warning!");
  logger.e("Error! Something bad happened", "Test Error");
  loggerNoStack.v({"key": 5, "value": "something"});
  Future.delayed(Duration(seconds: 5), log);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FlatButton(
          child: Text('Press to open log'),
          onPressed: () {
            LogConsole(
              incoming: logOut.stream,
            );
          },
        ),
      ),
    );
  }
}
