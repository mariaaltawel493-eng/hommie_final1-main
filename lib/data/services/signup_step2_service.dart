import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:hommie/data/models/signup/signup_step2_model.dart';

// ═══════════════════════════════════════════════════════════
// SIGNUP STEP 2 SERVICE - UPDATED
// Added registerFinalize method to save user to database
// ═══════════════════════════════════════════════════════════

class SignupStep2Service extends GetxService {
  final String baseUrl = 'http://192.168.1.3:8000/api';

  // ═══════════════════════════════════════════════════════════
  // STEP 1: Register Page 2 - Save email, password, role
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> registerStep2({
    required int pendingUserId,
    required SignupStep2Model signupStep2Data,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register/page2');

    final body = {
      "pending_user_id": pendingUserId,
      "email": signupStep2Data.email,
      "password": signupStep2Data.password,
      "role": signupStep2Data.role.name,
    };

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📤 API CALL: registerPage2');
      print('──────────────────────────────────────────────────────────');
      print('Request sent to: $url');
      print('Request body: $body');
      
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('──────────────────────────────────────────────────────────');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('═══════════════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      if (response.statusCode == 422) {
        return {
          'error': 'Validation error',
          'details': jsonDecode(response.body),
        };
      }

      return {
        'error': 'Failed: ${response.statusCode}',
        'details': response.body,
      };
    } catch (e) {
      print('❌ Exception in registerStep2: $e');
      return {'error': e.toString()};
    }
  }

  // ═══════════════════════════════════════════════════════════
  // STEP 2: Register Finalize - Save user to database
  // THIS IS THE MISSING STEP!
  // ═══════════════════════════════════════════════════════════
  
  Future<Map<String, dynamic>> registerFinalize({
    required int pendingUserId,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register/finalize');

    final body = {
      "pending_user_id": pendingUserId,
    };

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📤 API CALL: registerFinalize');
      print('──────────────────────────────────────────────────────────');
      print('Request sent to: $url');
      print('Request body: $body');
      
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('──────────────────────────────────────────────────────────');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('═══════════════════════════════════════════════════════════');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      if (response.statusCode == 422) {
        return {
          'error': 'Validation error',
          'details': jsonDecode(response.body),
        };
      }

      return {
        'error': 'Failed to finalize registration: ${response.statusCode}',
        'details': response.body,
      };
    } catch (e) {
      print('❌ Exception in registerFinalize: $e');
      return {'error': e.toString()};
    }
  }
}