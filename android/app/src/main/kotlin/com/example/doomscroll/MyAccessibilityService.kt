package com.example.doomscroll

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.accessibilityservice.AccessibilityServiceInfo
import android.util.Log  // Import Log for logging

class MyAccessibilityService : AccessibilityService() {

    override fun onServiceConnected() {
        // Configure the service info for event types and feedback
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.DEFAULT
        }
        this.serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let {
            // Check if the event is a window state change
            if (it.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
                // Extract the package name of the app that triggered the event
                val packageName = it.packageName?.toString()

                // Log the package name of the current app
                Log.d("AccessibilityService", "Current app package: $packageName")

                // If the package name matches Instagram, you can perform your desired action
                if (packageName == "com.instagram.android") {
                    // Instagram is in the foreground
                    // Example action: Log the event or trigger a behavior
                    Log.d("AccessibilityService", "Instagram is in the foreground")
                }
            }
        }
    }

    override fun onInterrupt() {
        // Handle service interruptions (e.g., the service is interrupted or stopped)
        // In most cases, you don't need to do anything here, but you can release resources if needed
    }
}
