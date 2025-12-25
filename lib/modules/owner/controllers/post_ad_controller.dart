import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/models/apartment/owner_apartment_model.dart';
import 'package:hommie/data/models/user/user_permission_controller.dart';
import 'package:hommie/data/repositories/apartment_repository.dart';
import 'package:image_picker/image_picker.dart';

// ═══════════════════════════════════════════════════════════
// UPDATED POST AD CONTROLLER
// With Approval System and Image Handling
// ═══════════════════════════════════════════════════════════

class PostAdController extends GetxController {
  final ApartmentRepository repo;
  PostAdController(this.repo);

  // ADD THIS: Get permissions controller
  final permissions = Get.find<UserPermissionsController>();

  List<OwnerApartmentModel> get myApartments => repo.apartments;

  OwnerApartmentModel? draft;

  Future<void> load() async => repo.load();

  void startNewDraft() {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📝 STARTING NEW DRAFT');
    print('═══════════════════════════════════════════════════════════');
    
    draft = OwnerApartmentModel(
      id: UniqueKey().toString(),
      title: "",
      description: "",
      governorate: "",
      city: "",
      address: "",
      pricePerDay: 0,
      roomsCount: 1,
      apartmentSize: 0,
      images: [],
      mainImage: null,
    );
    
    print('✅ New draft created');
  }

  // ═══════════════════════════════════════════════════════════
  // SAVE BASIC INFO
  // ═══════════════════════════════════════════════════════════
  Future<void> saveDraftBasicInfo({
    required String title,
    required String description,
    required String governorate,
    required String city,
    required String address,
    required double pricePerDay,
    required int roomsCount,
    required double apartmentSize,
  }) async {
    if (draft == null) startNewDraft();
    
    print('');
    print('📋 Saving basic info:');
    print('   Title: $title');
    print('   Governorate: $governorate');
    print('   City: $city');
    print('   Price: \$$pricePerDay/day');
    print('   Rooms: $roomsCount');
    print('   Size: ${apartmentSize}m²');
    
    draft!
      ..title = title
      ..description = description
      ..governorate = governorate
      ..city = city
      ..address = address
      ..pricePerDay = pricePerDay
      ..roomsCount = roomsCount
      ..apartmentSize = apartmentSize;
      
    print('✅ Basic info saved to draft');
  }

  // ═══════════════════════════════════════════════════════════
  // SAVE IMAGES FROM URLs
  // ═══════════════════════════════════════════════════════════
  Future<void> saveDraftImages({
    required List<String> images,
    required String mainImage,
  }) async {
    if (draft == null) return;
    
    print('');
    print('🖼️  Saving image URLs:');
    print('   Images count: ${images.length}');
    print('   Main image: $mainImage');
    
    draft!
      ..images = images
      ..mainImage = mainImage;
      
    print('✅ Images saved to draft');
  }

  // ═══════════════════════════════════════════════════════════
  // SAVE IMAGES FROM FILES (UPDATED IMPLEMENTATION)
  // ═══════════════════════════════════════════════════════════
  Future<void> saveDraftImagesFromFiles({
    required List<XFile> imageFiles,
    XFile? mainImageFile,
  }) async {
    if (draft == null) {
      print('⚠️  No draft found, creating new one');
      startNewDraft();
    }

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📸 SAVING IMAGES FROM FILES');
    print('═══════════════════════════════════════════════════════════');
    print('   Total images: ${imageFiles.length}');
    print('   Main image: ${mainImageFile != null ? "Yes" : "No"}');

    // Convert XFile paths to image URLs/paths for storage
    List<String> imagePaths = imageFiles.map((file) => file.path).toList();
    String? mainImagePath = mainImageFile?.path;

    draft!
      ..images = imagePaths
      ..mainImage = mainImagePath ?? (imagePaths.isNotEmpty ? imagePaths.first : null);

    print('✅ Images saved:');
    print('   Images: ${imagePaths.length} files');
    print('   Main image: ${draft!.mainImage}');
    print('═══════════════════════════════════════════════════════════');
  }

  // ═══════════════════════════════════════════════════════════
  // PUBLISH DRAFT (WITH PERMISSION CHECK)
  // ═══════════════════════════════════════════════════════════
  Future<void> publishDraft() async {
    if (draft == null) {
      print('⚠️  No draft to publish');
      return;
    }

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🚀 PUBLISHING DRAFT');
    print('═══════════════════════════════════════════════════════════');
    print('   Title: ${draft!.title}');
    print('   Price: \$${draft!.pricePerDay}/day');
    print('   Location: ${draft!.governorate}, ${draft!.city}');
    print('──────────────────────────────────────────────────────────');

    // CHECK PERMISSION FIRST
    if (!permissions.checkPermission('post', showMessage: true)) {
      print('❌ Publish denied - User not approved');
      print('   Is Approved: ${permissions.isApproved.value}');
      print('   Role: ${permissions.userRole.value}');
      print('═══════════════════════════════════════════════════════════');
      return;
    }

    print('✅ Permission granted - Publishing apartment');

    try {
      await repo.add(draft!);
      
      print('✅ APARTMENT PUBLISHED SUCCESSFULLY');
      print('   Apartment ID: ${draft!.id}');
      print('   Total apartments: ${myApartments.length}');
      print('═══════════════════════════════════════════════════════════');
      
      draft = null;
      
      Get.snackbar(
        '✅ نجح النشر',
        'تم نشر الشقة بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
      
    } catch (e) {
      print('❌ PUBLISH FAILED');
      print('   Error: $e');
      print('═══════════════════════════════════════════════════════════');
      
      Get.snackbar(
        '❌ خطأ',
        'فشل نشر الشقة: $e',
        backgroundColor: AppColors.failure,
        colorText: AppColors.backgroundLight,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // DELETE APARTMENT
  // ═══════════════════════════════════════════════════════════
  Future<void> deleteApartment(String id) async {
    print('');
    print('🗑️  Deleting apartment: $id');
    
    await repo.remove(id);
    
    print('✅ Apartment deleted');
  }

  // ═══════════════════════════════════════════════════════════
  // UPDATE APARTMENT
  // ═══════════════════════════════════════════════════════════
  Future<void> updateApartment(OwnerApartmentModel apt) async {
    print('');
    print('📝 Updating apartment: ${apt.title}');
    
    await repo.edit(apt);
    
    print('✅ Apartment updated');
  }

  // ═══════════════════════════════════════════════════════════
  // NAVIGATION HELPER WITH PERMISSION CHECK
  // ═══════════════════════════════════════════════════════════
  void onAddApartmentPressed() {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('➕ ADD APARTMENT BUTTON PRESSED');
    print('──────────────────────────────────────────────────────────');

    // CHECK PERMISSION FIRST
    if (!permissions.checkPermission('post', showMessage: true)) {
      print('❌ Add apartment denied - User not approved');
      print('   Is Approved: ${permissions.isApproved.value}');
      print('   Role: ${permissions.userRole.value}');
      print('═══════════════════════════════════════════════════════════');
      return;
    }

    print('✅ Permission granted - Opening apartment form');
    print('═══════════════════════════════════════════════════════════');
    
    startNewDraft();
    
    // Navigate to add apartment form
    // Get.to(() => ApartmentFormView(isEdit: false));
  }

  // ═══════════════════════════════════════════════════════════
  // GETTER FOR UI
  // ═══════════════════════════════════════════════════════════
  bool get canAddApartment => permissions.canPostApartments;
}