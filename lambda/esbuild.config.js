const esbuild = require('esbuild');

esbuild.build({
  entryPoints: ['index.ts'],
  bundle: true,
  minify: true,
  platform: 'node',
  target: 'node18',
  outfile: 'build/index.js',
  external: ['aws-sdk']
}).catch(() => process.exit(1));
