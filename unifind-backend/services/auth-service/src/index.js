import { config } from '@unifind/shared/config';
import { bootstrapService } from '@unifind/shared/service';
import { router } from './routes.js';

bootstrapService({ name: 'auth-service', port: config.ports.auth, routes: [['/auth', router]] });
