import { useEffect, useState, useRef } from 'react';
import type { EventSubscription } from 'react-native';
import NativeTimezoneHermesFix from './NativeTimezoneHermesFix';

/**
 * A React hook that provides real-time timezone information and automatically updates
 * when the device timezone changes.
 *
 * This hook addresses timezone-related issues in Hermes JavaScript engine by:
 * - Providing the current timezone name
 * - Listening for timezone changes and updating the state accordingly
 * - Properly cleaning up event subscriptions to prevent memory leaks
 *
 * @returns An object containing the current timezone information
 * @returns returns.currentTimezone - The name of the current device timezone (e.g., "America/New_York")
 *
 * @example
 * ```tsx
 * import { useTimezoneHermesFix } from './useTimezoneHermesFix';
 *
 * function MyComponent() {
 *   const { currentTimezone } = useTimezoneHermesFix();
 *
 *   return (
 *     <Text>Current timezone: {currentTimezone}</Text>
 *   );
 * }
 * ```
 */
const useTimezoneHermesFix = () => {
  const onTimezoneChangeSubscription = useRef<null | EventSubscription>(null);

  const [currentTimezone, setCurrentTimezone] = useState(
    NativeTimezoneHermesFix.getCurrentTimeZone().name
  );
  useEffect(() => {
    onTimezoneChangeSubscription.current =
      NativeTimezoneHermesFix.onTimezoneChange((timezoneInfo) => {
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
