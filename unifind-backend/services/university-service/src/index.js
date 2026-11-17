import { config } from '@unifind/shared/config';
import { bootstrapService } from '@unifind/shared/service';
import { router } from './routes.js';

bootstrapService({ name: 'university-service', port: config.ports.university, routes: [['/university', router]] });
