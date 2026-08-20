#import "TimezoneHermesFix.h"
#import <ReactCommon/RCTTurboModule.h>
#import <ReactCommon/CallInvoker.h>
#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>
#import <React/RCTUtils.h>
#include <jsi/jsi.h>
#include <hermes/hermes.h>

@implementation TimezoneHermesFix
{
  NSString *_currentTimezoneName;
  std::shared_ptr<facebook::react::CallInvoker> _jsInvoker;
}

RCT_EXPORT_MODULE()

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
  if (_jsInvoker == nullptr) {
    NSLog(@"TimezoneHermesFix: jsInvoker is null");
    return;
  }

  __weak TimezoneHermesFix *weakSelf = self;
  _jsInvoker->invokeAsync([weakSelf](facebook::jsi::Runtime &runtime) {
    facebook::hermes::HermesRuntime *hermesRuntime =
    dynamic_cast<facebook::hermes::HermesRuntime *>(&runtime);

    if (hermesRuntime != nullptr) {
      try {
        hermesRuntime->resetTimezoneCache();

        TimezoneHermesFix *strongSelf = weakSelf;
        if (strongSelf != nil) {
          [strongSelf emitOnTimezoneChange:[strongSelf getCurrentTimeZone]];
        }

        NSLog(@"TimezoneHermesFix: Successfully called resetTimezoneCache on Hermes runtime");
      } catch (const std::exception &e) {
        NSLog(@"TimezoneHermesFix: Exception calling resetTimezoneCache: %s", e.what());
      }
    } else {
      NSLog(@"TimezoneHermesFix: dynamic_cast to HermesRuntime failed");
    }
  });
}

/// CODEGEN
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
(const facebook::react::ObjCTurboModule::InitParams &)params
{
  _jsInvoker = params.jsInvoker;
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
