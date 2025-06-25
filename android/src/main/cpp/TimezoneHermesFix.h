#pragma once

#include <jni.h>
#include <jsi/jsi.h>
#include <ReactCommon/CallInvokerHolder.h>
#include <fbjni/fbjni.h>

using namespace facebook;

class TimezoneHermesFix: public jni::HybridClass<TimezoneHermesFix> {
public:
    static constexpr auto kJavaDescriptor = "Lcom/timezonehermesfix/TimezoneHermesFixModule;";
    static void registerNatives();
    static jni::local_ref<jhybriddata> initHybrid(jni::alias_ref<jhybridobject>);

    void coSieDzieje(jlong jsRuntimePtr);

private:
    friend HybridBase;
    TimezoneHermesFix() {}
};
