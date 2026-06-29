const esbuild = require('esbuild');

// @aws-sdk/* v3 is NOT pre-installed on Node 18 Lambda — it must be bundled.
esbuild.build({
  entryPoints: ['src/handler.ts'],
  bundle: true,
  minify: true,
  platform: 'node',
  target: 'node18',
  outfile: 'build/index.js',
}).catch(() => process.exit(1));
