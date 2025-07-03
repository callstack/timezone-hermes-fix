# Timezone Hermes Fix

**Timezone Hermes Fix** is a cross-platform React Native library that provides a workaround for timezone-related issues when using the Hermes JavaScript engine. It includes native modules for both Android and iOS, and is designed to be used as a drop-in fix for React Native projects that rely on accurate timezone handling.
It fixes timezone calculation [issues](https://github.com/facebook/hermes/pull/1693)

## Installation

### 1. Add the package

Using Yarn:

```sh
yarn add timezone-hermes-fix
```

Or with npm:

```sh
npm install timezone-hermes-fix
```

## Usage

### Basic Usage

Import and use the hook or module in your React Native code:

```tsx
import { useTimezoneHermesFix } from 'timezone-hermes-fix';

export default function App() {
  const { currentTimezone } = useTimezoneHermesFix();
  const date = new Date();
  return (
    <View>
      <Text>Current Timezone: {currentTimezone}</Text>
    </View>
  );
}
```

Or, if you want to call the native module directly:

```tsx
import { NativeTimezoneHermesFix } from 'timezone-hermes-fix';

const timezone = NativeTimezoneHermesFix.getCurrentTimeZone();
console.log(timezone.name); // "America/New_York"
console.log(timezone.secondsFromGMT); // -18000 (for EST)
console.log(timezone.isDaylightSavingTime); // true/false

const timezones = NativeTimezoneHermesFix.getSupportedTimeZones();
console.log(timezones); // ["America/New_York", "Europe/London", "Asia/Tokyo",

// Listen for timezone changes
const subscription = NativeTimezoneHermesFix.onTimezoneChange.addListener(
  (newTimezone) => {
    console.log('Timezone changed to:', newTimezone.name);
    console.log('New offset:', newTimezone.secondsFromGMT);
  }
);

// Don't forget to remove the listener when done
subscription.remove();
```

### Example App

A full example is provided in the `example/` directory. To run it:

```sh
cd example
yarn install
# For Android
yarn android
# For iOS
yarn ios
```

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Made with ❤️ at Callstack

`timezone-hermes-fix` is an open source project and will always remain free to use. If you think it's cool, please star it 🌟. [Callstack][callstack-readme-with-love] is a group of React and React Native geeks, contact us at [hello@callstack.com](mailto:hello@callstack.com) if you need any help with these or just want to say hi!

Like the project? ⚛️ [Join the team](https://callstack.com/careers/?utm_campaign=Senior_RN&utm_source=github&utm_medium=readme) who does amazing stuff for clients and drives React Native Open Source! 🔥

<!-- badges -->

[callstack-readme-with-love]: https://callstack.com/?utm_source=github.com&utm_medium=referral&utm_campaign=repack&utm_term=readme-with-love
