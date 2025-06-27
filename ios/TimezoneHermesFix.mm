#import "TimezoneHermesFix.h"
#import <ReactCommon/RCTTurboModule.h>
#import <jsi/jsi.h>
#import <React/RCTBridge+Private.h>
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>
#import <React/RCTUtils.h>
#include <jsi/jsi.h>
#include <hermes/hermes.h>

@implementation TimezoneHermesFix
{
  NSString *_currentTimezoneName;
}

RCT_EXPORT_MODULE()

@synthesize bridge = _bridge;

- (instancetype)init {
  self = [super init];
  if (self) {
    _currentTimezoneName = [[NSTimeZone localTimeZone] name];
    [self startTimezoneChangeDetection];
  }
  return self;
}

- (void)dealloc {
  [self stopTimezoneChangeDetection];
}

- (void)startTimezoneChangeDetection {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(timezoneDidChange:)
                                               name:NSSystemTimeZoneDidChangeNotification
                                             object:nil];
}

- (void)stopTimezoneChangeDetection {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NSSystemTimeZoneDidChangeNotification
                                                object:nil];
}

- (void)timezoneDidChange:(NSNotification *)notification {
  NSString *newTimezoneName = [[NSTimeZone localTimeZone] name];
  
  if (![newTimezoneName isEqualToString:_currentTimezoneName]) {
    _currentTimezoneName = newTimezoneName;
    [self onTimezoneChanged];
  }
}

- (void)onTimezoneChanged {
  RCTCxxBridge *cxxBridge = (RCTCxxBridge *)self.bridge;
  if (cxxBridge == nil) {
    NSLog(@"TimezoneHermesFix: cxxBridge is null");
    return;
  }
  
  [cxxBridge dispatchBlock:^{
    facebook::jsi::Runtime *jsiRuntime = (facebook::jsi::Runtime *)cxxBridge.runtime;
    if (jsiRuntime == nil) {
      NSLog(@"TimezoneHermesFix: jsiRuntime is null");
      return;
    }
    
    facebook::hermes::HermesRuntime *hermesRuntime =
    reinterpret_cast<facebook::hermes::HermesRuntime*>(jsiRuntime);
    
    if (hermesRuntime != nullptr) {
      try {
        hermesRuntime->resetTimezoneCache();
        [self emitOnTimezoneChange:[self getCurrentTimeZone]];
        
        NSLog(@"TimezoneHermesFix: Successfully called resetTimezoneCache on Hermes runtime");
      } catch (const std::exception &e) {
        NSLog(@"TimezoneHermesFix: Exception calling resetTimezoneCache: %s", e.what());
      }
    } else {
      NSLog(@"TimezoneHermesFix: reinterpret_cast to HermesRuntime failed");
    }
  } queue:RCTJSThread];
}

/// CODEGEN
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
(const facebook::react::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<facebook::react::NativeTimezoneHermesFixSpecJSI>(params);
}


- (nonnull NSDictionary *)getCurrentTimeZone {
  NSTimeZone *tz = [NSTimeZone localTimeZone];
  NSDictionary *timezoneInfo = @{
    @"name": tz.name,
    @"secondsFromGMT": @(tz.secondsFromGMT),
    @"isDaylightSavingTime": @(tz.isDaylightSavingTime)
  };
  return timezoneInfo;
}

- (nonnull NSArray<NSString *> *)getSupportedTimeZones {
  return [NSTimeZone knownTimeZoneNames];
}

@end
