#include "TimezoneHermesFix.h"
#include <jsi/jsi.h>
#include <jsi/hermes-interfaces.h>
#include <android/log.h>
#include <sys/system_properties.h>

using namespace facebook;

#define LOG_TAG "TimezoneHermesFix"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

void TimezoneHermesFix::registerNatives() {
    registerHybrid({
        makeNativeMethod("initHybrid", TimezoneHermesFix::initHybrid),
        makeNativeMethod("resetTzHermes", TimezoneHermesFix::resetTzHermes),
        makeNativeMethod("getSystemTimezoneId", TimezoneHermesFix::getSystemTimezoneId),
    });
}

jni::local_ref<TimezoneHermesFix::jhybriddata> TimezoneHermesFix::initHybrid(
    jni::alias_ref<jhybridobject> jThis,
    jni::alias_ref<react::CallInvokerHolder::javaobject> callInvokerHolder) {
    std::shared_ptr<react::CallInvoker> callInvoker;
    if (callInvokerHolder) {
        callInvoker = callInvokerHolder->cthis()->getCallInvoker();
    }
    return makeCxxInstance(jni::make_weak(jThis), std::move(callInvoker));
}

std::string TimezoneHermesFix::getSystemTimezoneId(jni::alias_ref<jclass>) {
    char value[PROP_VALUE_MAX] = {0};
    __system_property_get("persist.sys.timezone", value);
    return std::string(value);
}

bool TimezoneHermesFix::resetTzHermes(std::string timezoneName) {
    if (!callInvoker_) {
        LOGE("No CallInvoker for this module's JS runtime");
        return false;
    }

    auto javaPart = javaPart_;
    // The CallInvoker hands us the live runtime of the instance this module
    // belongs to, so there is no raw runtime pointer to go stale (same as iOS).
    callInvoker_->invokeAsync(
        [javaPart, timezoneName = std::move(timezoneName)](jsi::Runtime& runtime) {
            auto hermesRuntime = jsi::castInterface<facebook::hermes::IHermes>(&runtime);
            if (hermesRuntime == nullptr) {
                LOGE("The JS runtime does not implement IHermes");
                return;
            }

            try {
                hermesRuntime->resetTimezoneCache();
                LOGD("Reset Hermes timezone cache for %s", timezoneName.c_str());
            } catch (const std::exception& error) {
                LOGE("Exception calling resetTimezoneCache: %s", error.what());
                return;
            }

            auto module = javaPart.lockLocal();
            if (!module) {
                return;
            }
            try {
                static const auto onReset =
                    javaClassStatic()->getMethod<void(jni::local_ref<jstring>)>(
                        "onHermesTimezoneReset");
                onReset(module, jni::make_jstring(timezoneName));
            } catch (const std::exception& error) {
                LOGE("Exception notifying Java of the reset: %s", error.what());
            }
        });
    return true;
}
