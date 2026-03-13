package com.dlg.digital_literacy_guardian

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val EVENT_CHANNEL = "com.dlg.digital_literacy_guardian/notifications"
    private val METHOD_CHANNEL = "com.dlg.digital_literacy_guardian/methods"

    private var eventSink: EventChannel.EventSink? = null

    private val notificationReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val title = intent.getStringExtra("title") ?: ""
            val text = intent.getStringExtra("text") ?: ""
            val packageName = intent.getStringExtra("package") ?: ""

            // Send to Flutter
            val data = mapOf(
                "title" to title,
                "text" to text,
                "package" to packageName
            )
            eventSink?.success(data)
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup EventChannel for streaming notifications
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    val filter = IntentFilter("com.dlg.digital_literacy_guardian.NOTIFICATION_EVENT")
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                        registerReceiver(notificationReceiver, filter, RECEIVER_EXPORTED)
                    } else {
                        registerReceiver(notificationReceiver, filter)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    try {
                        unregisterReceiver(notificationReceiver)
                    } catch (e: Exception) {
                        // Receiver might not be registered
                    }
                }
            }
        )

        // Setup MethodChannel for checking/requesting permissions
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isNotificationListenerEnabled" -> {
                    val enabledListeners = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
                    val packageName = packageName
                    val isEnabled = enabledListeners?.contains(packageName) == true
                    result.success(isEnabled)
                }
                "openNotificationListenerSettings" -> {
                    val intent = Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
