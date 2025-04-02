import 'package:flutter/material.dart';

class ScrollEndNotifier extends ChangeNotifier {
  void scrollEnd() => notifyListeners();
}