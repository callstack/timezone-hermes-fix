import React, { useState } from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  useColorScheme,
  View,
  TouchableHighlight,
} from 'react-native';

import {
  useTimezoneHermesFix,
  NativeTimezoneHermesFix,
} from 'timezone-hermes-fix';

const stringDate = 'Mon Apr 28 2025 22:50:36 GMT+0900';

const TimezoneAwareComponent = () => {
  const { currentTimezone } = useTimezoneHermesFix();
  const date = new Date(stringDate);

  return (
    <View style={styles.card}>
      <Text style={styles.cardTitle}>Timezone fix</Text>
      <Text style={styles.timezoneText}>{currentTimezone}</Text>
      <Text style={styles.dateText}>
        {date.toLocaleTimeString()} - TimezoneOffset {date.getTimezoneOffset()}
      </Text>
    </View>
  );
};

const DateComponent = () => {
  const date = new Date(stringDate);

  return (
    <View style={styles.card}>
      <Text style={styles.cardTitle}>No timezone fix</Text>
      <Text style={styles.dateText}>
        {date.toLocaleTimeString()} - TimezoneOffset {date.getTimezoneOffset()}
      </Text>
    </View>
  );
};

const TimezonesListComponent = () => {
  const [showAll, setShowAll] = useState(false);
  const timezones = NativeTimezoneHermesFix.getSupportedTimeZones();
  const displayTimezones = showAll ? timezones : timezones.slice(0, 5);

  return (
    <View style={styles.card}>
      <Text style={styles.cardTitle}>Available Timezones</Text>
      {displayTimezones.map((timezone) => (
        <Text key={timezone} style={styles.timezoneItem}>
          {timezone}
        </Text>
      ))}
      <TouchableHighlight
        onPress={() => setShowAll(!showAll)}
        style={styles.button}
      >
        <Text style={styles.buttonText}>
          {showAll ? 'Show Less' : 'Show More'}
        </Text>
      </TouchableHighlight>
    </View>
  );
};

function App(): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';

  const backgroundStyle = {
    backgroundColor: isDarkMode ? '#1a1a1a' : '#f5f5f5',
    flex: 1,
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
        contentContainerStyle={styles.scrollContent}
      >
        <View style={styles.container}>
          <Text style={[styles.title, isDarkMode && styles.titleDark]}>
            Timezone Demo
          </Text>
          <TimezoneAwareComponent />
          <DateComponent />
          <TimezonesListComponent />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  scrollContent: {
    flexGrow: 1,
  },
  container: {
    padding: 16,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    marginBottom: 24,
    color: '#000',
  },
  titleDark: {
    color: '#fff',
  },
  card: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 12,
    color: '#1a1a1a',
  },
  timezoneText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#007AFF',
    marginBottom: 8,
  },
  dateText: {
    fontSize: 16,
    color: '#666',
  },
  timezoneItem: {
    fontSize: 14,
    color: '#333',
    paddingVertical: 4,
  },
  button: {
    backgroundColor: '#007AFF',
    padding: 8,
    borderRadius: 8,
    marginTop: 12,
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
});

export default App;
