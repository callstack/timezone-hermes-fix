project(TimezoneHermesFix)
cmake_minimum_required(VERSION 3.9.0)

set(PACKAGE_NAME "timezone-hermes-fix")

# Add your sources
add_library(
    ${PACKAGE_NAME}
    SHARED
    src/main/cpp/TimezoneHermesFix.cpp
    src/main/cpp/OnLoad.cpp
)

# Configure C++ 17
set_target_properties(
    ${PACKAGE_NAME}
    PROPERTIES
    CXX_STANDARD 17
    CXX_EXTENSIONS OFF
    POSITION_INDEPENDENT_CODE ON
    LINKER_LANGUAGE CXX
)

find_package(fbjni REQUIRED CONFIG)
find_package(ReactAndroid REQUIRED CONFIG)
find_package(hermes-engine REQUIRED CONFIG)
string(APPEND CMAKE_CXX_FLAGS " -DJS_RUNTIME_HERMES=1")

target_link_libraries(
        ${PACKAGE_NAME}
        hermes-engine::libhermes
)

target_include_directories(
    ${PACKAGE_NAME}
    PRIVATE
    "src/main/cpp"
    "${REACT_NATIVE_DIR}/ReactCommon"
    "${REACT_NATIVE_DIR}/ReactCommon/callinvoker"
    "${REACT_NATIVE_DIR}/ReactAndroid/src/main/jni/react/turbomodule"
    # Add Hermes include directories
    "${REACT_NATIVE_DIR}/ReactCommon/hermes"
    "${REACT_NATIVE_DIR}/third-party/hermes/API"
)

# Link libraries
if(ReactAndroid_VERSION_MINOR GREATER_EQUAL 76)
    target_link_libraries(
        ${PACKAGE_NAME}
        ReactAndroid::reactnative
    )
else()
    target_link_libraries(
        ${PACKAGE_NAME}
        ReactAndroid::reactnativejni
    )
endif()

target_link_libraries(
    ${PACKAGE_NAME}
    android
    log
    fbjni::fbjni
    ReactAndroid::jsi
)

