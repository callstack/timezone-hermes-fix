/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  Text,
  useColorScheme,
  View,
} from 'react-native';

// TODO Describe differences between react-native-localize and this library
//import * as RNLocalize from 'react-native-localize';
import {
  useTimezoneHermesFix,
  NativeTimezoneHermesFix,
} from 'timezone-hermes-fix';

const TimezoneAwareComponent = () => {
  const { currentTimezone } = useTimezoneHermesFix();

  const date = new Date(
    'Mon Apr 28 2025 22:50:36 GMT+0900 (Japan Standard Time)'
  );

  return (
    <View>
      <Text>Current timezone: {currentTimezone}</Text>
      <Text>
        Date: {date.getHours()}:{date.getMinutes()}
      </Text>
    </View>
  );
};

const DateComponent = () => {
  const date = new Date(
    'Mon Apr 28 2025 22:50:36 GMT+0900 (Japan Standard Time)'
  );
  return (
    <View>
      <Text>
        Fixed Date: {date.getHours()}:{date.getMinutes()}
      </Text>
    </View>
  );
};

function App(): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';

  const backgroundStyle = {
    backgroundColor: 'white',
  };

  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar
        barStyle={isDarkMode ? 'light-content' : 'dark-content'}
        backgroundColor={backgroundStyle.backgroundColor}
      />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={backgroundStyle}
      >
        <View
          style={{
            backgroundColor: 'white',
          }}
        >
          {/* TODO Add some interesting styles*/}
          <TimezoneAwareComponent />
          <DateComponent />
          {/* TODO add a second tab */}
          {NativeTimezoneHermesFix.getSupportedTimeZones().map((x) => (
            <Text key={x}>{x}</Text>
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

export default App;
