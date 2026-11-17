// Starts the gateway and all services in one terminal (prefixed logs). Ctrl+C stops everything.
import { spawn } from 'node:child_process';

const apps = ['gateway', 'services/auth-service', 'services/university-service', 'services/rating-service',
  'services/test-service', 'services/blog-service', 'services/audit-service'];
const watch = process.argv.includes('--watch');
const children = apps.map((dir) => {
  const label = dir.split('/').pop();
  const child = spawn('node', [...(watch ? ['--watch'] : []), `${dir}/src/index.js`], { stdio: ['ignore', 'pipe', 'pipe'] });
  for (const stream of [child.stdout, child.stderr]) {
    stream.on('data', (d) => d.toString().split('\n').filter(Boolean).forEach((l) => console.log(`[${label}] ${l}`)));
  }
  child.on('exit', (code) => { if (code) { console.error(`[${label}] exited with ${code}`); shutdown(); } });
  return child;
});
function shutdown() { children.forEach((c) => c.kill('SIGTERM')); setTimeout(() => process.exit(0), 500); }
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
