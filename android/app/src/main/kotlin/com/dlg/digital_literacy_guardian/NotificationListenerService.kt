package com.dlg.digital_literacy_guardian

import android.app.Notification
import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class NotificationListenerService : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        sbn?.let {
            val packageName = it.packageName
            val extras = it.notification.extras
            val title = extras.getString(Notification.EXTRA_TITLE) ?: ""
            val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""

            // Only broadcast if there's actual text content to analyze
            if (title.isNotEmpty() || text.isNotEmpty()) {
                val intent = Intent("com.dlg.digital_literacy_guardian.NOTIFICATION_EVENT")
                intent.putExtra("package", packageName)
                intent.putExtra("title", title)
                intent.putExtra("text", text)
                sendBroadcast(intent)
            }
        }
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        // Notify the app that the listener is connected and active
        val intent = Intent("com.dlg.digital_literacy_guardian.NOTIFICATION_STATUS")
        intent.putExtra("status", "connected")
        sendBroadcast(intent)
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        val intent = Intent("com.dlg.digital_literacy_guardian.NOTIFICATION_STATUS")
        intent.putExtra("status", "disconnected")
        sendBroadcast(intent)
    }
}
