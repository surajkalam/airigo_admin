import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';
  static const String _userTypeKey = 'user_type';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  late SharedPreferences _prefs;

  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() => _instance;

  LocalStorageService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User email
  String? get userEmail => _prefs.getString(_userEmailKey);
  Future<void> setUserEmail(String email) async {
    await _prefs.setString(_userEmailKey, email);
  }
  Future<void> removeUserEmail() async {
    await _prefs.remove(_userEmailKey);
  }

  // User phone
  String? get userPhone => _prefs.getString(_userPhoneKey);
  Future<void> setUserPhone(String phone) async {
    await _prefs.setString(_userPhoneKey, phone);
  }
  Future<void> removeUserPhone() async {
    await _prefs.remove(_userPhoneKey);
  }

  // User type
  String? get userType => _prefs.getString(_userTypeKey);
  Future<void> setUserType(String type) async {
    await _prefs.setString(_userTypeKey, type);
  }
  Future<void> removeUserType() async {
    await _prefs.remove(_userTypeKey);
  }

  // Login status
  bool get isLoggedIn => _prefs.getBool(_isLoggedInKey) ?? false;
  Future<void> setLoggedIn(bool loggedIn) async {
    await _prefs.setBool(_isLoggedInKey, loggedIn);
  }
  Future<void> setLoggedOut() async {
    await _prefs.setBool(_isLoggedInKey, false);
  }

  // Onboarding status
  bool get isOnboardingCompleted => _prefs.getBool(_onboardingCompletedKey) ?? false;
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_onboardingCompletedKey, completed);
  }

  // Clear all user data
  Future<void> clearAllUserData() async {
    await removeUserEmail();
    await removeUserPhone();
    await removeUserType();
    await setLoggedOut();
  }
}