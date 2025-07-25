package com.timezonehermesfix

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import androidx.annotation.RequiresApi
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.WritableNativeMap
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.turbomodule.core.CallInvokerHolderImpl
import com.facebook.react.common.annotations.FrameworkAPI
import com.facebook.jni.HybridData
import java.util.Date
import java.util.TimeZone

@ReactModule(name = TimezoneHermesFixModule.NAME)
class TimezoneHermesFixModule(reactContext: ReactApplicationContext) :
  NativeTimezoneHermesFixSpec(reactContext) {

  private val mHybridData: HybridData = initHybrid()
  private val mReactContext: ReactApplicationContext = reactContext
  private var receiver: BroadcastReceiver? = null
  private var currentTimezoneName: String = TimeZone.getDefault().id

  private external fun initHybrid(): HybridData
  private external fun resetTzHermes(jsRuntimePtr: Long)

  init {
    receiver = object : BroadcastReceiver() {
      override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Intent.ACTION_TIMEZONE_CHANGED) {
          val newTimezoneName = TimeZone.getDefault().id
          if (newTimezoneName != currentTimezoneName) {
            currentTimezoneName = newTimezoneName
            onTimezoneChanged()
          }
        }
      }
    }

    val filter = IntentFilter(Intent.ACTION_TIMEZONE_CHANGED)
    mReactContext.registerReceiver(receiver, filter)
  }

  @OptIn(FrameworkAPI::class)
  private fun onTimezoneChanged() {
    try {
      val catalystInstance = mReactContext.catalystInstance
      if (catalystInstance == null) {
        android.util.Log.e(NAME, "CatalystInstance is null")
        return
      }

      val callInvokerHolder = catalystInstance.jsCallInvokerHolder as? CallInvokerHolderImpl
      if (callInvokerHolder == null) {
        android.util.Log.e(NAME, "CallInvokerHolder is null or not of expected type")
        return
      }

      val javaScriptContextHolder = mReactContext.javaScriptContextHolder
      if (javaScriptContextHolder == null) {
        android.util.Log.e(NAME, "JavaScriptContextHolder is null")
        return
      }

      val jsRuntimePtr = javaScriptContextHolder.get()
      if (jsRuntimePtr == 0L) {
        android.util.Log.e(NAME, "JSI Runtime pointer is null")
        return
      }

      resetTzHermes(jsRuntimePtr)
      emitOnTimezoneChange(getCurrentTimeZone())

    } catch (e: Exception) {
      android.util.Log.e(NAME, "Error resetting Hermes timezone cache: ${e.message}", e)
    }
  }

  override fun getName(): String {
    return NAME
  }
  
  override fun getCurrentTimeZone(): WritableMap {
    val tz = TimeZone.getDefault()
    val timezoneInfo = WritableNativeMap()
    timezoneInfo.putString("name", tz.id)
    timezoneInfo.putInt("secondsFromGMT", tz.getOffset(Date().time) / 1000)
    timezoneInfo.putBoolean("isDaylightSavingTime", tz.inDaylightTime(Date()))
    return timezoneInfo
  }

  override fun getSupportedTimeZones(): WritableArray {
    val timezones = TimeZone.getAvailableIDs()
    val result = WritableNativeArray()
    for (timezone in timezones) {
      result.pushString(timezone)
    }
    return result
  }

  override fun invalidate() {
    receiver?.let {
      mReactContext.unregisterReceiver(it)
      receiver = null
    }
    super.invalidate()
  }

  companion object {
    init {
      System.loadLibrary("timezone-hermes-fix")
    }
    const val NAME = "TimezoneHermesFix"
  }
}
