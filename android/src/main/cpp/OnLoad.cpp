#include <jni.h>
#include <fbjni/fbjni.h>
#include "TimezoneHermesFix.h"

using namespace facebook::jni;

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *) {
    return initialize(vm, [] {
        TimezoneHermesFix::registerNatives();
    });
}