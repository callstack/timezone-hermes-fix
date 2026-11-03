#pragma once

#include <jni.h>
#include <ReactCommon/CallInvoker.h>
#include <ReactCommon/CallInvokerHolder.h>
#include <fbjni/fbjni.h>

#include <memory>
#include <string>

class TimezoneHermesFix : public facebook::jni::HybridClass<TimezoneHermesFix> {
public:
    static constexpr auto kJavaDescriptor = "Lcom/timezonehermesfix/TimezoneHermesFixModule;";
    static void registerNatives();
    static facebook::jni::local_ref<jhybriddata> initHybrid(
        facebook::jni::alias_ref<jhybridobject> jThis,
        facebook::jni::alias_ref<facebook::react::CallInvokerHolder::javaobject> callInvokerHolder);

    // Schedules a Hermes timezone cache reset on the JS thread of the runtime
    // this module belongs to. Returns false when it cannot be scheduled.
    bool resetTzHermes(std::string timezoneName);

    // Reads the zone bionic (and therefore Hermes) uses, bypassing the
    // per-process java.util.TimeZone default cache.
    static std::string getSystemTimezoneId(facebook::jni::alias_ref<jclass>);

private:
    friend HybridBase;
    TimezoneHermesFix(
        facebook::jni::weak_ref<jhybridobject> javaPart,
        std::shared_ptr<facebook::react::CallInvoker> callInvoker)
        : javaPart_(std::move(javaPart)), callInvoker_(std::move(callInvoker)) {}

    // Weak, so the C++ part does not keep the Java module alive.
    facebook::jni::weak_ref<jhybridobject> javaPart_;
    std::shared_ptr<facebook::react::CallInvoker> callInvoker_;
};
