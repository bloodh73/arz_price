import 'package:flutter/material.dart';
import 'package:gold/widgets/custom_snackbar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  static const String GITHUB_API =
      'https://api.github.com/repos/bloodh73/gold/releases/latest';

  static Future<void> checkForUpdate(BuildContext context) async {
    // نمایش دیالوگ با نوار پیشرفت
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('در حال بررسی بروزرسانی...'),
            ],
          ),
        );
      },
    );

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await Dio().get(GITHUB_API);
      final latestVersion = response.data['tag_name'].toString().replaceAll(
        'v',
        '',
      );
      final downloadUrl = response.data['assets']?[0]?['browser_download_url'];
      final changelog = response.data['body'] ?? '';
      final isDark = Theme.of(context).brightness == Brightness.dark;

      // بستن دیالوگ نوار پیشرفت
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // مقایسه نسخه‌ها
      if (_isNewerVersion(currentVersion, latestVersion)) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('بروزرسانی جدید'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('نسخه جدید $latestVersion در دسترس است.'),
                      const SizedBox(height: 8),
                      const Text('تغییرات:'),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(changelog),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('بعد<lemma'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      if (downloadUrl != null) {
                        final Uri url = Uri.parse(downloadUrl);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          if (context.mounted) {
                            CustomSnackBar.showError(
                              context: context,
                              message: 'خطا در باز کردن لینک دانلود',
                            );
                          }
                        }
                      }
                    },
                    child: const Text('دانلود'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        if (context.mounted) {
          CustomSnackBar.showInfo(
            context: context,
            message: 'برنامه شما به‌روز است',
          );
        }
      }
    } catch (e) {
      // بستن دیالوگ نوار پیشرفت در صورت خطا
      if (context.mounted) {
        Navigator.of(context).pop();
        CustomSnackBar.showError(
          context: context,
          message: 'خطا در بررسی بروزرسانی: ${e.toString()}',
        );
      }
    }
  }

  // مقایسه نسخه‌ها برای تشخیص جدیدتر بودن
  static bool _isNewerVersion(String currentVersion, String latestVersion) {
    List<int> current = currentVersion.split('.').map(int.parse).toList();
    List<int> latest = latestVersion.split('.').map(int.parse).toList();

    // اطمینان از اینکه هر دو لیست طول یکسانی دارند
    while (current.length < latest.length) {
      current.add(0);
    }
    while (latest.length < current.length) {
      latest.add(0);
    }

    // مقایسه نسخه‌ها
    for (int i = 0; i < current.length; i++) {
      if (latest[i] > current[i]) {
        return true;
      } else if (latest[i] < current[i]) {
        return false;
      }
    }

    return false; // نسخه‌ها یکسان هستند
  }
}
