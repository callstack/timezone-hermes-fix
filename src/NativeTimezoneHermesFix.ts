import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';
import type { EventEmitter } from 'react-native/Libraries/Types/CodegenTypes';

type CurrentTimezone = {
  name: string;
  secondsFromGMT: number;
  isDaylightSavingTime: boolean;
};
export interface Spec extends TurboModule {
  getCurrentTimeZone(): CurrentTimezone;
  getSupportedTimeZones(): string[];
  readonly onTimezoneChange: EventEmitter<CurrentTimezone>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('TimezoneHermesFix');
