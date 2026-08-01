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

    final statuses = await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    final allGranted = statuses.values.every((s) => s.isGranted);

    setState(() {
      ready = allGranted;
      checking = false;
    });

    // اگه همه مجوزها داده نشده، یک بار دیگه می‌پرسیم (نه حلقه بی‌نهایت)
    if (!allGranted) {
      // فقط یه پیام نشون بده و دکمه بذار برای تلاش مجدد
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
