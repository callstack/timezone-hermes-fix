# 🕐 Timezone Hermes Fix

<!-- TODO -->
<!-- [![npm version](https://badge.fury.io/js/timezone-hermes-fix.svg)](https://badge.fury.io/js/timezone-hermes-fix)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI](https://github.com/callstack/timezone-hermes-fix/workflows/CI/badge.svg)](https://github.com/callstack/timezone-hermes-fix/actions) -->

**Timezone Hermes Fix** is a cross-platform React Native library that provides a robust workaround for timezone-related issues when using the Hermes JavaScript engine. It includes native modules for both Android and iOS, designed as a drop-in solution for React Native projects requiring accurate timezone handling.

## 🚀 Support
<!-- https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts -->

> [!WARNING]  
> This library is supported from React Native 0.80.2 and above.

## 🔧 The Problem

React Native apps using the Hermes JavaScript engine may experience timezone calculation issues, particularly when:

- The device timezone changes while the app is running
- Date/time calculations don't reflect the current timezone
- Inconsistent behavior across different devices or regions

This library fixes these [known issues](https://github.com/facebook/hermes/pull/1693) by providing native timezone cache reset.

## 📦 Installation

### Using Yarn (recommended)

```sh
yarn add @callstack/timezone-hermes-fix
```

### Using npm

```sh
npm install @callstack/timezone-hermes-fix
```

## 🎯 Usage

### Quick Start with Hook

The easiest way to use the library is with the provided React hook:

```tsx
import React from 'react';
import { View, Text } from 'react-native';
import { useTimezoneHermesFix } from '@callstack/timezone-hermes-fix';

export default function App() {
  const { currentTimezone } = useTimezoneHermesFix();

  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <Text>Current Timezone: {currentTimezone}</Text>
      <Text>Current Time: {new Date().toLocaleString()}</Text>
    </View>
  );
}
```

### Direct Native Module Usage

For more control, you can use the native module directly:

```tsx
import { NativeTimezoneHermesFix } from '@callstack/timezone-hermes-fix';

// Get current timezone information
const timezone = NativeTimezoneHermesFix.getCurrentTimeZone();
console.log('Timezone:', timezone.name); // "America/New_York"
console.log('GMT Offset:', timezone.secondsFromGMT); // -18000 (for EST)
console.log('DST Active:', timezone.isDaylightSavingTime); // true/false

// Get all supported timezones
const supportedTimezones = NativeTimezoneHermesFix.getSupportedTimeZones();
console.log('Available timezones:', supportedTimezones.length);

// Listen for timezone changes
const subscription = NativeTimezoneHermesFix.onTimezoneChange.addListener(
  (newTimezone) => {
    console.log('Timezone changed to:', newTimezone.name);
    console.log('New GMT offset:', newTimezone.secondsFromGMT);
    console.log('DST status:', newTimezone.isDaylightSavingTime);
  }
);

// Clean up listener when component unmounts
// subscription.remove();
```

## 📱 API Reference

### Types

```typescript
type CurrentTimezone = {
  name: string; // e.g., "America/New_York"
  secondsFromGMT: number; // Offset in seconds from GMT
  isDaylightSavingTime: boolean; // Whether DST is currently active
};
```

### Methods

#### `getCurrentTimeZone(): CurrentTimezone`

Returns the current timezone information.

#### `getSupportedTimeZones(): string[]`

Returns an array of all supported timezone identifiers.

#### `onTimezoneChange: EventEmitter<CurrentTimezone>`

Event emitter that fires when the device timezone changes.

### Hook

#### `useTimezoneHermesFix(): { currentTimezone: string }`

React hook that automatically updates when the timezone changes.

## 🧪 Example App

A complete example app is included in the repository. To run it:

```sh
# Clone the repository
git clone https://github.com/callstack/timezone-hermes-fix.git
cd timezone-hermes-fix

# Install dependencies
yarn

# Run on iOS
yarn example ios

# Run on Android
yarn example android
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Made with ❤️ at Callstack

`@callstack/timezone-hermes-fix` is an open source project and will always remain free to use. If you think it's cool, please star it 🌟. Callstack is a group of React and React Native geeks, contact us at hello@callstack.com if you need any help with these or just want to say hi!
