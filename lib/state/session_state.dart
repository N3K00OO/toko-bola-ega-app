import 'package:flutter/foundation.dart';

import '../models/session_user.dart';

class SessionState extends ChangeNotifier {
  SessionUser? _user;

  SessionUser? get user => _user;
  bool get isLoggedIn => _user != null;

  void update(SessionUser user) {
    _user = user;
    notifyListeners();
  }

  void updateLastLogin(String? lastLogin) {
    if (_user == null) return;
    _user = _user!.copyWith(lastLogin: lastLogin);
    notifyListeners();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}
