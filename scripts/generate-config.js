#!/usr/bin/env node

/**
 * Generate docusaurus.config.js from Handlebars template
 * 
 * This script safely generates docusaurus.config.js using Handlebars templating
 * to prevent string injection vulnerabilities. All user input is properly escaped.
 * 
 * Usage:
 *   npm run generate-config -- \
 *     --site-name "My Site" \
 *     --site-id "site-123" \
 *     --site-url "https://mysite.docusapiens.ai" \
 *     --github-repo "owner/repo"
 * 
 * All parameters are required and will be properly escaped by Handlebars.
 */

const fs = require('fs');
const path = require('path');
const Handlebars = require('handlebars');

// Parse command line arguments
const args = process.argv.slice(2);
const params = {};

for (let i = 0; i < args.length; i += 2) {
  const key = args[i].replace(/^--/, '');
  const value = args[i + 1];
  params[key] = value;
}

// Validate required parameters
const required = ['site-name', 'site-id', 'site-url', 'github-repo'];
const missing = required.filter(key => !params[key]);

if (missing.length > 0) {
  console.error('Error: Missing required parameters:', missing.join(', '));
  console.error('\nUsage:');
  console.error('  npm run generate-config -- \\');
  console.error('    --site-name "My Site" \\');
  console.error('    --site-id "site-123" \\');
  console.error('    --site-url "https://mysite.docusapiens.ai" \\');
  console.error('    --github-repo "owner/repo"');
  process.exit(1);
}

// Determine template path (relative to script location)
const scriptDir = __dirname;
const templatePath = path.join(scriptDir, '..', 'docusaurus.config.js.hbs');
const outputPath = path.join(scriptDir, '..', 'docusaurus.config.js');

// Check if template exists
if (!fs.existsSync(templatePath)) {
  console.error(`Error: Template file not found: ${templatePath}`);
  process.exit(1);
}

// Read template
const templateContent = fs.readFileSync(templatePath, 'utf8');
const template = Handlebars.compile(templateContent);

// Parse GitHub repo
const githubRepo = params['github-repo'];
const [organizationName, projectName] = githubRepo.split('/');

if (!organizationName || !projectName) {
  console.error(`Error: Invalid GitHub repo format. Expected "owner/repo", got: ${githubRepo}`);
  process.exit(1);
}

// Prepare template data
// Handlebars automatically escapes all values to prevent injection
const templateData = {
  siteName: params['site-name'],
  siteId: params['site-id'],
  siteUrl: params['site-url'],
  repoName: githubRepo,
  organizationName: organizationName,
  projectName: projectName,
};

// Generate config
try {
  const configContent = template(templateData);
  
  // Write output file
  fs.writeFileSync(outputPath, configContent, 'utf8');
  
  console.log('✓ Successfully generated docusaurus.config.js');
  console.log(`  Template: ${path.relative(process.cwd(), templatePath)}`);
  console.log(`  Output: ${path.relative(process.cwd(), outputPath)}`);
  console.log(`  Site: ${templateData.siteName} (${templateData.siteId})`);
  console.log(`  URL: ${templateData.siteUrl}`);
  console.log(`  Repo: ${templateData.repoName}`);
  
  process.exit(0);
} catch (error) {
  console.error('Error generating config:', error.message);
  process.exit(1);
}
