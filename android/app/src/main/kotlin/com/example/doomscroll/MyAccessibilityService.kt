package com.example.doomscroll

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import io.flutter.plugin.common.EventChannel

class MyAccessibilityService : AccessibilityService() {

    companion object {
        var scrollCounter: Int = 0
        // Integrated EventChannel sink for sending scroll count updates
        var eventSink: EventChannel.EventSink? = null

        // Landmark constants (in feet)
        const val IGLOO_HEIGHT = 5.0
        const val QUTUB_MINAR_HEIGHT = 240.0
        const val EIFFEL_TOWER_HEIGHT = 984.0
        const val EMPIRE_STATE_BUILDING_HEIGHT = 1250.0
        const val BURJ_KHALIFA_HEIGHT = 2717.0
    }

    private var isScrolling: Boolean = false  // Flag to track if a scroll event is already processed
    private val scrollDelay: Long = 650L        // Delay in ms

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
                        // Only process if not already handling a scroll
                        if (!isScrolling) {
                            isScrolling = true

                            // Increment the static counter and calculate swipe length
                            scrollCounter++
                            val swipeLength = scrollCounter * 6.5
                            Log.d("MyAccessibilityService", "Scroll event count: $scrollCounter, Total swipe length: $swipeLength ft")

                            // Compare the swipe length against our landmarks
                            when {
                                swipeLength < IGLOO_HEIGHT ->
                                    Log.d("MyAccessibilityService", "Swipe length is less than an Igloo ($IGLOO_HEIGHT ft)")
                                swipeLength < QUTUB_MINAR_HEIGHT ->
                                    Log.d("MyAccessibilityService", "Swipe length is between an Igloo ($IGLOO_HEIGHT ft) and Qutub Minar ($QUTUB_MINAR_HEIGHT ft)")
                                swipeLength < EIFFEL_TOWER_HEIGHT ->
                                    Log.d("MyAccessibilityService", "Swipe length is between Qutub Minar ($QUTUB_MINAR_HEIGHT ft) and the Eiffel Tower ($EIFFEL_TOWER_HEIGHT ft)")
                                swipeLength < EMPIRE_STATE_BUILDING_HEIGHT ->
                                    Log.d("MyAccessibilityService", "Swipe length is between the Eiffel Tower ($EIFFEL_TOWER_HEIGHT ft) and the Empire State Building ($EMPIRE_STATE_BUILDING_HEIGHT ft)")
                                swipeLength < BURJ_KHALIFA_HEIGHT ->
                                    Log.d("MyAccessibilityService", "Swipe length is between the Empire State Building ($EMPIRE_STATE_BUILDING_HEIGHT ft) and Burj Khalifa ($BURJ_KHALIFA_HEIGHT ft)")
                                else ->
                                    Log.d("MyAccessibilityService", "Swipe length exceeds Burj Khalifa ($BURJ_KHALIFA_HEIGHT ft)")
                            }

                            Log.d("MyAccessibilityService", "Instagram scroll detected!")

                            // Send the updated scroll counter to Flutter via the EventChannel
                            eventSink?.success(scrollCounter)

                            // Delay before allowing the next scroll event
                            Handler(Looper.getMainLooper()).postDelayed({
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