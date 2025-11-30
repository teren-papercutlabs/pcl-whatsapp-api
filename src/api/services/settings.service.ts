import { InstanceDto } from '@api/dto/instance.dto';
import { SettingsDto } from '@api/dto/settings.dto';
import { BadRequestException } from '@exceptions';
import { Logger } from '@config/logger.config';

import { WAMonitoringService } from './monitor.service';

export class SettingsService {
  constructor(private readonly waMonitor: WAMonitoringService) {}

  private readonly logger = new Logger('SettingsService');

  public async create(instance: InstanceDto, data: SettingsDto) {
    // Validate alwaysOnline setting - can only be true when instance is connected
    if (data.alwaysOnline === true) {
      const waInstance = this.waMonitor.waInstances[instance.instanceName];
      if (!waInstance || waInstance.connectionStatus?.state !== 'open') {
        throw new BadRequestException('Cannot enable "Always Online" while instance is disconnected. Please connect the instance first.');
      }
    }

    await this.waMonitor.waInstances[instance.instanceName].setSettings(data);

    return { settings: { ...instance, settings: data } };
  }

  public async find(instance: InstanceDto): Promise<SettingsDto> {
    try {
      const result = await this.waMonitor.waInstances[instance.instanceName].findSettings();

      if (Object.keys(result).length === 0) {
        throw new Error('Settings not found');
      }

      return result;
    } catch {
      return null;
    }
  }
}
