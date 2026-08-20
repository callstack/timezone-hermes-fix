#import "TimezoneHermesFix.h"
#import <UIKit/UIKit.h>
#import <ReactCommon/RCTTurboModule.h>
#import <ReactCommon/CallInvoker.h>
#include <jsi/jsi.h>
#include <jsi/hermes-interfaces.h>

@implementation TimezoneHermesFix
{
  NSString *_currentTimezoneName;
  std::shared_ptr<facebook::react::CallInvoker> _jsInvoker;
  BOOL _isObservingTimezoneChanges;
}

RCT_EXPORT_MODULE()

- (instancetype)init {
  self = [super init];
  if (self) {
    _currentTimezoneName = [[NSTimeZone localTimeZone] name];
  }
  return self;
}

- (void)dealloc {
  [self stopTimezoneChangeDetection];
}

- (void)startTimezoneChangeDetection {
  if (_isObservingTimezoneChanges) {
    return;
  }

  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter addObserver:self
                         selector:@selector(timezoneDidChange:)
                             name:NSSystemTimeZoneDidChangeNotification
                           object:nil];
  [notificationCenter addObserver:self
                         selector:@selector(applicationDidBecomeActive:)
                             name:UIApplicationDidBecomeActiveNotification
                           object:nil];
  _isObservingTimezoneChanges = YES;
}

- (void)stopTimezoneChangeDetection {
  if (!_isObservingTimezoneChanges) {
    return;
  }

  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter removeObserver:self
                                 name:NSSystemTimeZoneDidChangeNotification
                               object:nil];
  [notificationCenter removeObserver:self
                                 name:UIApplicationDidBecomeActiveNotification
                               object:nil];
  _isObservingTimezoneChanges = NO;
}

- (void)timezoneDidChange:(NSNotification *)notification {
  [self checkForTimezoneChange];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
  [self checkForTimezoneChange];
}

- (void)checkForTimezoneChange {
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
    facebook::hermes::IHermes *hermesRuntime =
        facebook::jsi::castInterface<facebook::hermes::IHermes>(&runtime);

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
      NSLog(@"TimezoneHermesFix: active JS runtime does not implement IHermes");
    }
  });
}

/// CODEGEN
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
(const facebook::react::ObjCTurboModule::InitParams &)params
{
  _jsInvoker = params.jsInvoker;
  [self startTimezoneChangeDetection];
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
