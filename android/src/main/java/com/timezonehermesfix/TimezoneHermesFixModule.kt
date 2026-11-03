package com.timezonehermesfix

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import com.facebook.jni.HybridData
import com.facebook.proguard.annotations.DoNotStrip
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.WritableNativeMap
import com.facebook.react.common.annotations.FrameworkAPI
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.turbomodule.core.CallInvokerHolderImpl
import java.util.Date
import java.util.TimeZone

/**
 * Resets the Hermes zone cache after the device zone changes. The reset is
 * scheduled through this module's CallInvoker, which runs it on the JS thread
 * with the live runtime of the instance the module belongs to (as on iOS).
 * A resume checks the zone too: a broadcast sent while the app was cached can
 * arrive late. The zone is read from the system property bionic and Hermes
 * use, because java.util.TimeZone's per-process default may still be stale.
 */
@OptIn(FrameworkAPI::class)
@ReactModule(name = TimezoneHermesFixModule.NAME)
class TimezoneHermesFixModule(reactContext: ReactApplicationContext) :
  NativeTimezoneHermesFixSpec(reactContext), LifecycleEventListener {

  private val mHybridData: HybridData =
    initHybrid(reactContext.jsCallInvokerHolder as? CallInvokerHolderImpl)
  private val mReactContext: ReactApplicationContext = reactContext
  private var receiver: BroadcastReceiver? = null

  // The zone Hermes was last reset to. Updated only after a reset has run,
  // so a reset that could not happen is retried on the next check.
  private var appliedTimezoneName: String = systemTimezoneId()

  private external fun initHybrid(callInvokerHolder: CallInvokerHolderImpl?): HybridData
  private external fun resetTzHermes(timezoneName: String): Boolean

  init {
    receiver = object : BroadcastReceiver() {
      override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Intent.ACTION_TIMEZONE_CHANGED) checkForTimezoneChange()
      }
    }
    mReactContext.registerReceiver(receiver, IntentFilter(Intent.ACTION_TIMEZONE_CHANGED))
    mReactContext.addLifecycleEventListener(this)
  }

  override fun onHostResume() = checkForTimezoneChange()

  override fun onHostPause() = Unit

  override fun onHostDestroy() = Unit

  @Synchronized
  private fun checkForTimezoneChange() {
    try {
      val newTimezoneName = systemTimezoneId()
      if (newTimezoneName == appliedTimezoneName) return
      if (!resetTzHermes(newTimezoneName)) {
        Log.e(NAME, "Could not schedule the Hermes timezone cache reset")
      }
    } catch (e: Throwable) {
      Log.e(NAME, "Error resetting Hermes timezone cache: ${e.message}", e)
    }
  }

  /** Called from C++ on the JS thread after Hermes reset its zone cache. */
  @DoNotStrip
  private fun onHermesTimezoneReset(timezoneName: String) {
    synchronized(this) {
      if (timezoneName == appliedTimezoneName) return
      appliedTimezoneName = timezoneName
    }
    try {
      emitOnTimezoneChange(getCurrentTimeZone())
    } catch (e: Exception) {
      Log.e(NAME, "Error emitting timezone change: ${e.message}", e)
    }
  }

  override fun getName(): String {
    return NAME
  }

  override fun getCurrentTimeZone(): WritableMap {
    val tz = TimeZone.getTimeZone(systemTimezoneId())
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
    mReactContext.removeLifecycleEventListener(this)
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

    @JvmStatic
    private external fun getSystemTimezoneId(): String

    private fun systemTimezoneId(): String =
      getSystemTimezoneId().ifEmpty { TimeZone.getDefault().id }
  }
}
