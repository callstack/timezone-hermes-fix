#include "TimezoneHermesFix.h"
#include <jsi/jsi.h>
#include <ReactCommon/CallInvokerHolder.h>
#include <fbjni/fbjni.h>
#include <hermes/hermes.h>
#include <android/log.h>

using namespace facebook;
using namespace facebook::jni;
using namespace facebook::react;
using namespace facebook::hermes;

#define LOG_TAG "TimezoneHermesFix"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

void TimezoneHermesFix::registerNatives() {
    registerHybrid({
        makeNativeMethod("initHybrid", TimezoneHermesFix::initHybrid),
        makeNativeMethod("resetTzHermes", TimezoneHermesFix::resetTzHermes),
    });
}

jni::local_ref<TimezoneHermesFix::jhybriddata> TimezoneHermesFix::initHybrid(
    jni::alias_ref<jhybridobject>) {
    return makeCxxInstance();
}

void TimezoneHermesFix::resetTzHermes(jlong jsRuntimePtr) {
    LOGD("resetTzHermes called with jsRuntimePtr: %ld", jsRuntimePtr);

    // Get JSI Runtime pointer (equivalent to iOS cxxBridge.runtime)
    auto jsiRuntime = reinterpret_cast<jsi::Runtime*>(jsRuntimePtr);
    if (jsiRuntime == nullptr) {
        LOGE("jsiRuntime is null");
        return;
    }

    // Cast to HermesRuntime (equivalent to iOS reinterpret_cast)
    auto hermesRuntime = reinterpret_cast<HermesRuntime*>(jsiRuntime);
    if (hermesRuntime == nullptr) {
        LOGE("hermesRuntime is null - not running on Hermes");
        return;
    }

    try {
        // Call resetTimezoneCache on Hermes runtime (same as iOS)
        hermesRuntime->resetTimezoneCache();
        LOGD("Successfully called resetTimezoneCache on Hermes runtime");

    } catch (const jsi::JSError& error) {
        LOGE("JSI Error calling resetTimezoneCache: %s", error.getMessage().c_str());
    } catch (const std::exception& error) {
        LOGE("Exception calling resetTimezoneCache: %s", error.what());
    }
}
