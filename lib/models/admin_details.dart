class AdminDetails {
  static const String email = 'admin@moodtracker.com';
  static const String password = 'AdminPassword123!';
  static const String username = 'SuperAdmin';
  
  static bool isAdmin(String inputEmail) {
    return inputEmail == email;
  }
}
