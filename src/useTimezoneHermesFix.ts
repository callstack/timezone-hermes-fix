// Example usage in React Native
import { useEffect, useState } from 'react';
import type { EventSubscription } from 'react-native';
import NativeTimezoneHermesFix from './NativeTimezoneHermesFix';
import * as React from 'react';

const useTimezoneHermesFix = () => {
  const onTimezoneChangeSubscription = React.useRef<null | EventSubscription>(
    null
  );

  const [currentTimezone, setCurrentTimezone] = useState(
    NativeTimezoneHermesFix.getCurrentTimeZone().name
  );
  useEffect(() => {
    onTimezoneChangeSubscription.current =
      NativeTimezoneHermesFix.onTimezoneChange((timezoneInfo) => {
        console.log('Timezone changed:', timezoneInfo);
        setCurrentTimezone(timezoneInfo.name);
      });

    return () => {
      onTimezoneChangeSubscription.current?.remove();
      onTimezoneChangeSubscription.current = null;
    };
  }, []);

  return { currentTimezone };
};

export { useTimezoneHermesFix };
