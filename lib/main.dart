import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/main_shell.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MySecurityApp',
    theme: ThemeData.dark(),
    home: const PermissionHandler(),
  );
}

class PermissionHandler extends StatefulWidget {
  const PermissionHandler({super.key});
  @override
  State<PermissionHandler> createState() => _PermissionHandlerState();
}

class _PermissionHandlerState extends State<PermissionHandler> {
  bool ready = false;
  bool checking = true;

  @override
  void initState() {
    super.initState();
    _checkAll();
  }

  Future<void> _checkAll() async {
    setState(() => checking = true);

    // چک کردن همه مجوزها
    final storage = await Permission.storage.status;
    final manage = await Permission.manageExternalStorage.status;

    bool allOk = storage.isGranted && manage.isGranted;

    // اگه مجوز مدیریت فایل داده نشده، درخواست کن
    if (!manage.isGranted) {
      final result = await Permission.manageExternalStorage.request();
      allOk = storage.isGranted && result.isGranted;
    }

    // اگه مجوز storage داده نشده، درخواست کن
    if (!storage.isGranted) {
      final result = await Permission.storage.request();
      allOk = result.isGranted && manage.isGranted;
    }

    setState(() {
      ready = allOk;
      checking = false;
    });

    // اگه بازم نشد، دوباره چک کن
    if (!allOk) {
      Future.delayed(const Duration(seconds: 2), () {
        _checkAll();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ready) {
      return const MainShell();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (checking) ...[
              const CircularProgressIndicator(color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                'در حال بررسی مجوزها...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ] else ...[
              const Icon(Icons.warning, color: Colors.orange, size: 60),
              const SizedBox(height: 20),
              const Text(
                'لطفاً مجوز مدیریت فایل رو فعال کنید',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'برای اسکن کامل گوشی نیازه',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _checkAll,
                icon: const Icon(Icons.refresh),
                label: const Text('بررسی مجدد'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: openAppSettings,
                child: const Text(
                  'رفتن به تنظیمات دستی',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
