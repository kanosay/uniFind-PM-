import { config } from '@unifind/shared/config';
import { bootstrapService } from '@unifind/shared/service';
import { router } from './routes.js';

bootstrapService({ name: 'test-service', port: config.ports.test, routes: [['/test', router]] });
