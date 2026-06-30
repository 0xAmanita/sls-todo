const esbuild = require('esbuild');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// @aws-sdk/* v3 is NOT pre-installed on Node 18 Lambda — it must be bundled.
esbuild.build({
  entryPoints: ['src/handler.ts'],
  bundle: true,
  minify: true,
  platform: 'node',
  target: 'node18',
  outfile: 'build/index.js',
}).then(() => {
  console.log('Build complete, creating zip...');
  
  // Ensure build directory exists
  const buildDir = path.join(__dirname, 'build');
  if (!fs.existsSync(buildDir)) {
    fs.mkdirSync(buildDir, { recursive: true });
  }
  
  // Create zip file
  try {
    // Change to build directory and zip the index.js file
    execSync('cd build && zip -q function.zip index.js', { stdio: 'inherit' });
    console.log('Zip file created: build/function.zip');
  } catch (error) {
    console.error('Failed to create zip file:', error);
    process.exit(1);
  }
}).catch(() => process.exit(1));
