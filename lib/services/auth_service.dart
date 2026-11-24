
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Register a new student
  Future<void> registerStudent({
    required String fullName,
    required String email,
    required String password,
    required String department,
    required String academicYear,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'department': department,
        'academic_year': academicYear,
      },
    );
  }

  // Login an existing student
  Future<void> loginStudent({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> logoutStudent() async {
    await _supabase.auth.signOut();
  }
}
