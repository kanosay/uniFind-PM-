import { config } from '@unifind/shared/config';
import { bootstrapService } from '@unifind/shared/service';
import { router } from './routes.js';

bootstrapService({ name: 'audit-service', port: config.ports.audit, routes: [['/audit', router]] });
