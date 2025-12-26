import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/app/utils/theme/theme_service.dart';
import 'package:hommie/modules/shared/controllers/logout_controller.dart';
import 'package:hommie/app/utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LogoutController controller = Get.put(LogoutController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Profile Content',
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            // أضيفي هذا الكود هنا - فوق زر Log Out مباشرة
            // ... بعد الـSizedBox(height: 50),

            // قسم الإعدادات
            // قسم الإعدادات
            Container(
              width: 250,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 16),
                  // خيار Dark Mode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.dark_mode, color: AppColors.primary),
                          SizedBox(width: 10),
                          Text(
                            'Dark Mode',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      // الـSwitch الفعلي
                      Obx(() {
                        final box = GetStorage();
                        final isDarkMode = RxBool(
                          box.read('isDarkMode') ?? false,
                        );
                        return Switch(
                          value: isDarkMode.value,
                          onChanged: (value) {
                            Get.find<ThemeService>().toggleTheme();
                          },
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // مسافة قبل زر Log Out
            const SizedBox(height: 50),
            Obx(
              () => SizedBox(
                height: 50,
                width: 250,
                child: ElevatedButton(
                  onPressed: controller.isLoggingOut.value
                      ? null
                      : controller.handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: controller.isLoggingOut.value
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        )
                      : const Text(
                          'Log Out',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
