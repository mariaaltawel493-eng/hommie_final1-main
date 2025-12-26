import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/app/bindings/bindings.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/app/utils/theme/theme_service.dart';
import 'package:hommie/modules/renter/views/apartment_details_screen.dart';
import 'package:hommie/modules/renter/views/home.dart';
import 'package:hommie/modules/shared/views/startupscreen.dart';
import 'package:hommie/modules/shared/views/welcomescreen.dart';

import 'app/utils/theme/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(ThemeService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    return Obx(
      () => GetMaterialApp(
        theme: ThemeData(
          // الثيم الفاتح
          brightness: Brightness.light,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.backgroundLight,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.backgroundLight,
            foregroundColor: AppColors.textPrimaryLight,
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: AppColors.textPrimaryLight),
            bodyMedium: TextStyle(color: AppColors.textSecondaryLight),
          ),
        ),
        darkTheme: ThemeData(
          // الثيم الداكن
          brightness: Brightness.dark,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.backgroundDark,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.backgroundDark,
            foregroundColor: AppColors.textPrimaryDark,
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
            bodyMedium: TextStyle(color: AppColors.textSecondaryDark),
          ),
        ),
        themeMode: themeService.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        initialRoute: '/',
        initialBinding: InitialBinding(),
        routes: {
          '/': (context) => StartupScreen(),
          "home": (context) => RenterHomeScreen(),
          "welcome": (context) => WelcomeScreen(),
          "/apartment_details": (context) => ApartmentDetailsScreen(),
        },
      ),
    );
  }
}
