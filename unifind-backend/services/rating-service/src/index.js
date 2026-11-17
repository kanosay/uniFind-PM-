import { config } from '@unifind/shared/config';
import { bootstrapService } from '@unifind/shared/service';
import { reviewRouter, universityRatingRouter } from './routes.js';

bootstrapService({
  name: 'rating-service',
  port: config.ports.rating,
  routes: [['/university', universityRatingRouter], ['/review', reviewRouter]],
});
