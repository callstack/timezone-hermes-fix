import type { CodegenTypes, TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

type CurrentTimezone = {
  name: string;
  secondsFromGMT: number;
  isDaylightSavingTime: boolean;
};
export interface Spec extends TurboModule {
  getCurrentTimeZone(): CurrentTimezone;
  getSupportedTimeZones(): string[];
  readonly onTimezoneChange: CodegenTypes.EventEmitter<CurrentTimezone>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('TimezoneHermesFix');
