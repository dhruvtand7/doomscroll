package com.example.doomscroll

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.view.accessibility.AccessibilityManager
import android.accessibilityservice.AccessibilityServiceInfo
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "doomscroll/foreground_app"
    private val SCROLL_COUNT_CHANNEL = "doomscroll/scroll_count"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Existing method channel for accessibility-related methods
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestAccessibilityPermission" -> {
                    requestAccessibilityPermission()
                    result.success(null)
                }
                "isInstagramRunning" -> {
                    result.success(isInstagramRunning())
                }
                else -> result.notImplemented()
            }
        }

        // Set up the EventChannel for scroll count updates
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SCROLL_COUNT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    // Directly assign the event sink to the one in MyAccessibilityService
                    MyAccessibilityService.eventSink = events
                }
                override fun onCancel(arguments: Any?) {
                    MyAccessibilityService.eventSink = null
                }
            }
        )
    }

    private fun requestAccessibilityPermission() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }

    private fun isInstagramRunning(): Boolean {
        val am = getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
        val runningServices = am.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK)
        for (service in runningServices) {
            if (service.id.contains("com.instagram.android")) {
                return true
            }
        }
        return false
    }
}