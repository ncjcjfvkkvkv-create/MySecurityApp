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
  bool checking = false;

  @override
  void initState() {
    super.initState();
    _ask();
  }

  Future<void> _ask() async {
    if (checking) return;
    setState(() => checking = true);

    // مجوزهای معمولی
    final statuses = await [
      Permission.storage,
    ].request();

    // مجوز مدیریت فایل (Android 11+)
    PermissionStatus manageStorageStatus = await Permission.manageExternalStorage.status;
    if (!manageStorageStatus.isGranted) {
      manageStorageStatus = await Permission.manageExternalStorage.request();
    }

    final allGranted = statuses.values.every((s) => s.isGranted) && manageStorageStatus.isGranted;

    setState(() {
      ready = allGranted;
      checking = false;
    });

    if (!allGranted) {
      // اگه مجوز مدیریت فایل رو نداد، مستقیم به تنظیمات میفرستیم
      if (!manageStorageStatus.isGranted) {
        await openAppSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) => ready
      ? const MainShell()
      : Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (checking) ...[
                const CircularProgressIndicator(color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  'درخواست مجوز...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ] else ...[
                const Icon(Icons.warning, color: Colors.orange, size: 60),
                const SizedBox(height: 20),
                const Text(
                  'لطفاً همه مجوزها رو بدهید',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 10),
                const Text(
                  'باید مجوز "مدیریت فایل" رو فعال کنید',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _ask,
                  child: const Text('تلاش مجدد'),
                ),
              ],
            ],
          ),
        ),
      );
}
