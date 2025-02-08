package com.example.doomscroll

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.view.accessibility.AccessibilityEvent
import android.util.Log
import android.os.Handler
import android.os.Looper

class MyAccessibilityService : AccessibilityService() {

    private var isScrolling: Boolean = false  // Flag to track if a scroll event is already processed
    private val scrollDelay: Long = 650L  // Time delay to reduce sensitivity (500ms)

    override fun onServiceConnected() {
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_VIEW_SCROLLED or
                    AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.DEFAULT
        }
        serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let {
            val packageName = it.packageName?.toString()

            // Only track Instagram scrolling events
            if (packageName == "com.instagram.android") {
                when (it.eventType) {
                    AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                        Log.d("MyAccessibilityService", "Instagram is in the foreground")
                    }
                    AccessibilityEvent.TYPE_VIEW_SCROLLED -> {
                        // Check if a scroll event is already being processed
                        if (!isScrolling) {
                            // Set flag to indicate scrolling is in progress
                            isScrolling = true
                            Log.d("MyAccessibilityService", "Instagram scroll detected!")

                            // Simulate a short delay before allowing another scroll detection
                            Handler(Looper.getMainLooper()).postDelayed({
                                // Reset flag after the delay
                                isScrolling = false
                            }, scrollDelay)
                        } else {
                            Log.d("MyAccessibilityService", "Ignoring rapid scroll event")
                        }
                    }
                }
            }
        }
    }

    override fun onInterrupt() {
        Log.d("MyAccessibilityService", "Service Interrupted")
    }
}