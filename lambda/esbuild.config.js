const esbuild = require('esbuild');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Define all Lambda functions
const lambdaFunctions = [
  { entry: 'src/createTodo.ts', output: 'createTodo' },
  { entry: 'src/listTodos.ts', output: 'listTodos' },
  { entry: 'src/getTodo.ts', output: 'getTodo' },
  { entry: 'src/updateTodo.ts', output: 'updateTodo' },
  { entry: 'src/deleteTodo.ts', output: 'deleteTodo' },
];

// Ensure build directory exists
const buildDir = path.join(__dirname, 'build');
if (!fs.existsSync(buildDir)) {
  fs.mkdirSync(buildDir, { recursive: true });
}

// Build all Lambda functions
const buildPromises = lambdaFunctions.map(({ entry, output }) => {
  return esbuild.build({
    entryPoints: [entry],
    bundle: true,
    minify: true,
    platform: 'node',
    target: 'node18',
    outfile: `build/${output}.js`,
  }).then(() => {
    console.log(`Built ${output}.js`);
    
    // Create zip file for this function
    try {
      execSync(`cd build && zip -q ${output}.zip ${output}.js`, { stdio: 'inherit' });
      console.log(`Created ${output}.zip`);
      
      // Clean up the .js file after zipping
      fs.unlinkSync(path.join(buildDir, `${output}.js`));
    } catch (error) {
      console.error(`Failed to create zip file for ${output}:`, error);
      throw error;
    }
  });
});

Promise.all(buildPromises)
  .then(() => {
    console.log('\nBuild complete! Created zip files:');
    lambdaFunctions.forEach(({ output }) => {
      console.log(`  - build/${output}.zip`);
    });
  })
  .catch((error) => {
    console.error('Build failed:', error);
    process.exit(1);
  });
