import { config } from '@unifind/shared/config';
import { bootstrapService } from '@unifind/shared/service';
import { router } from './routes.js';

bootstrapService({ name: 'blog-service', port: config.ports.blog, routes: [['/blog', router]] });
