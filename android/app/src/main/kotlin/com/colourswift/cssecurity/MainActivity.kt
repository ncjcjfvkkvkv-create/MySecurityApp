package com.colourswift.cssecurity

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.PackageManager
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "cs.fastapps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "listUserApps" -> {
                        try {
                            val pm = packageManager
                            val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
                            val list = apps.mapNotNull { app ->
                                val sourceDir = app.sourceDir
                                if (sourceDir == null) return@mapNotNull null
                                mapOf(
                                    "name" to pm.getApplicationLabel(app).toString(),
                                    "path" to sourceDir,
                                    "packageName" to app.packageName
                                )
                            }
                            result.success(list)
                        } catch (e: Exception) {
                            result.error("LIST_FAILED", e.message, null)
                        }
                    }
                    "copyApkToCache" -> {
                        val packageName = call.argument<String>("packageName") ?: ""
                        if (packageName.isEmpty()) {
                            result.error("INVALID_ARG", "Package name required", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val pm = packageManager
                            val packageInfo = pm.getPackageInfo(packageName, 0)
                            val appInfo = packageInfo.applicationInfo
                            if (appInfo == null) {
                                result.error("COPY_FAILED", "ApplicationInfo is null", null)
                                return@setMethodCallHandler
                            }
                            val sourceDir = appInfo.sourceDir
                            if (sourceDir == null) {
                                result.error("COPY_FAILED", "Source dir is null", null)
                                return@setMethodCallHandler
                            }
                            val cacheDir = cacheDir.absolutePath
                            val apkFile = File(sourceDir)
                            val destFile = File("$cacheDir/$packageName.apk")
                            
                            apkFile.copyTo(destFile, overwrite = true)
                            result.success(destFile.absolutePath)
                        } catch (e: Exception) {
                            result.error("COPY_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
