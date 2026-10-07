package com.example.easy_english

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class ProgressWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        val day = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val current = widgetData.getString("updatedDay", "") == day
        val today = if (current) widgetData.getInt("today", 0) else 0
        val goal = widgetData.getInt("goal", 10)
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.progress_widget)
            views.setTextViewText(R.id.widget_progress, "$today / $goal сегодня")
            views.setTextViewText(R.id.widget_detail, if (current) "Серия: ${widgetData.getInt("streak", 0)} дн. · Повторить: ${widgetData.getInt("due", 0)}" else "Новый день — новые возможности")
            val intent = Intent(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_root, PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE))
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
