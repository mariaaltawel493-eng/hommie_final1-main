import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/data/models/signup/signup_step3_model.dart';
import 'package:hommie/data/services/signup_step3_service.dart';
import 'package:hommie/modules/auth/views/signup_step4.dart';


// ═══════════════════════════════════════════════════════════
// SIGNUP STEP 3 CONTROLLER - COMPLETE
// Handles first name, last name, date of birth
// Includes ALL methods needed by SignupStep3Screen
// ═══════════════════════════════════════════════════════════

class SignupStep3Controller extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();  // ✅ Add this for the screen
  
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final box = GetStorage();
  final RxBool isLoading = false.obs;
  
  // Date of birth
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  
  late final int pendingUserId;
  String? phoneNumber;
  String? email;
  String? role;

  final SignupStep3Service service = SignupStep3Service();

  @override
  void onInit() {
    super.onInit();
    
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📝 SIGNUP STEP 3 CONTROLLER - INITIALIZING');
    print('──────────────────────────────────────────────────────────');
    
    pendingUserId = Get.arguments['pendingUserId'];
    phoneNumber = Get.arguments['phoneNumber'] as String?;
    email = Get.arguments['email'] as String?;
    role = Get.arguments['role'] as String?;
    
    print('✅ Pending User ID: $pendingUserId');
    if (email != null) print('✅ Email: $email');
    if (phoneNumber != null) print('✅ Phone: $phoneNumber');
    if (role != null) print('✅ Role: $role');
    print('═══════════════════════════════════════════════════════════');
  }

  // ═══════════════════════════════════════════════════════════
  // VALIDATION METHODS (used by the screen)
  // ═══════════════════════════════════════════════════════════

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "This field cannot be empty";
    }
    if (value.length < 2) {
      return "Name must be at least 2 characters";
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return "Name can only contain letters";
    }
    return null;
  }

  String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return "Please select your date of birth";
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════
  // DATE PICKER
  // ═══════════════════════════════════════════════════════════

  Future<void> selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Must be 18+ years old
      helpText: 'Select your date of birth',
      fieldLabelText: 'Date of Birth',
    );
    
    if (picked != null) {
      selectedDate.value = picked;
      dobController.text = _formatDate(picked);  // ✅ Update the text field
      print('✅ Date of birth selected: ${dobController.text}');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ═══════════════════════════════════════════════════════════
  // NAVIGATION METHODS
  // ═══════════════════════════════════════════════════════════

  Future<void> goToStep3B() async {
    await completeStep3();
  }

  Future<void> goToNextStep() async {
    await completeStep3();
  }

  // ═══════════════════════════════════════════════════════════
  // SUBMIT STEP 3 DATA
  // ═══════════════════════════════════════════════════════════

  Future<void> completeStep3() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    if (selectedDate.value == null) {
      Get.snackbar(
        'Required',
        'Please select your date of birth',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📝 COMPLETING STEP 3 - Name & Date of Birth');
    print('──────────────────────────────────────────────────────────');
    print('   Pending User ID: $pendingUserId');
    print('   First Name: ${firstNameController.text}');
    print('   Last Name: ${lastNameController.text}');
    print('   Date of Birth: ${dobController.text}');
    print('──────────────────────────────────────────────────────────');

    isLoading.value = true;

    try {
      // ═══════════════════════════════════════════════════════════
      // Call registerPage3 API
      // ═══════════════════════════════════════════════════════════
      
      print('');
      print('📤 Calling registerPage3 API...');
      
      final step3Model = SignupStep3Model(
        pendingUserId: pendingUserId,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        dateOfBirth: dobController.text,  // Already formatted as YYYY-MM-DD
      );

      final response = await service.submitStep3(step3Model);

      isLoading.value = false;

      print('📥 Response from registerPage3: $response');

      if (response['success'] != true) {
        final error = response['error'] ?? 'Failed at step 3';
        print('❌ Error: $error');
        Get.snackbar(
          'Error',
          error.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      print('✅ RegisterPage3 SUCCESS');
      print('──────────────────────────────────────────────────────────');
      
      // ═══════════════════════════════════════════════════════════
      // Navigate to Step 4 (Upload Images)
      // ═══════════════════════════════════════════════════════════
      
      print('');
      print('➡️  Navigating to Step 4 (Upload Images)...');
      print('═══════════════════════════════════════════════════════════');
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      Get.to(
        () => const SignupStep4Screen(),
        arguments: {
          'pendingUserId': pendingUserId,
          'phoneNumber': phoneNumber,
          'email': email,
          'role': role,
          'firstName': firstNameController.text.trim(),
          'lastName': lastNameController.text.trim(),
        },
      );
      
    } catch (e) {
      isLoading.value = false;
      print('💥 Exception during step 3: $e');
      Get.snackbar(
        'Error',
        'Connection error. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    super.onClose();
  }
}