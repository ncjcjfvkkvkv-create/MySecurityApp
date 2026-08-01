import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/scan api/headless_scan.dart';
import '../screens/scan_ui_screen.dart';

class FullScanScreen extends StatefulWidget {
  const FullScanScreen({super.key});

  @override
  State<FullScanScreen> createState() => _FullScanScreenState();
}

class _FullScanScreenState extends State<FullScanScreen> {
  bool _isScanning = false;
  double _progress = 0.0;
  int _scannedItems = 0;
  int _totalItems = 0;
  List<Map<String, dynamic>> _scanResults = [];
  Timer? _timer;
  String _currentItem = '';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startScan() async {
    setState(() {
      _isScanning = true;
      _progress = 0.0;
      _scannedItems = 0;
      _scanResults.clear();
      _currentItem = 'Starting scan...';
    });

    // شبیه‌سازی اسکن (در واقعیت، اسکن واقعی انجام میشه)
    _timer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      setState(() {
        _scannedItems++;
        _progress = _scannedItems / 100;
        if (_progress > 1.0) _progress = 1.0;
        _currentItem = 'Scanning: item $_scannedItems';
        _scanResults.add({
          'name': 'App $_scannedItems',
          'path': '/storage/emulated/0/app_$_scannedItems.apk',
          'status': 'clean',
        });
        if (_scannedItems >= 100) {
          timer.cancel();
          setState(() {
            _isScanning = false;
            _currentItem = 'Scan complete!';
          });
        }
      });
    });

    // اجرای اسکن واقعی
    try {
      final result = await runHeadlessScan(
        mode: ScanMode.full,
        useCloud: false,
        quarantine: false,
        onEvent: (event) {
          if (event.type == 'current') {
            setState(() {
              _currentItem = event.name ?? 'Scanning...';
              _scannedItems = event.scanned ?? 0;
            });
          }
        },
      );
      setState(() {
        _progress = 1.0;
        _isScanning = false;
        _currentItem = 'Scan complete! Found ${result.threats} threats';
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _currentItem = 'Scan failed: $e';
      });
    }
  }

  void _stopScan() {
    _timer?.cancel();
    setState(() {
      _isScanning = false;
      _currentItem = 'Scan stopped';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Full Scan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // بخش سرعت‌سنج (Gauge)
          Expanded(
            flex: 2,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // دایره پس‌زمینه
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[800]!, width: 8),
                    ),
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _progress < 0.5 ? Colors.orange : Colors.green,
                      ),
                    ),
                  ),
                  // متن وسط
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _currentItem,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // لیست آیتم‌های اسکن‌شده
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$_scannedItems items scanned',
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                        Text(
                          '${_scanResults.where((e) => e['status'] == 'threat').length} threats',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _scanResults.length,
                      itemBuilder: (context, index) {
                        final item = _scanResults[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[800],
                            child: Icon(
                              item['status'] == 'threat' ? Icons.warning : Icons.check,
                              color: item['status'] == 'threat' ? Colors.red : Colors.green,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            item['name'] ?? 'Unknown',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          subtitle: Text(
                            item['path']?.split('/').last ?? '',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            item['status'] == 'threat' ? Icons.warning_amber : Icons.check_circle,
                            color: item['status'] == 'threat' ? Colors.red : Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // دکمه استاپ
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isScanning ? _stopScan : _startScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isScanning ? Colors.red : Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isScanning ? 'Stop Scan' : 'Start Full Scan',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
