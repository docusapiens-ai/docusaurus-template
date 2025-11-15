# Docusaurus Template

A modern documentation site template built with [Docusaurus 3](https://docusaurus.io/), featuring optimized builds, chat widget integration, and secure configuration generation using Handlebars.

## Features

- 📚 **Modern Documentation Site** - Built with Docusaurus 3
- ⚡ **Fast Builds** - Optimized for performance with Docusaurus Faster
- 💬 **Chat Integration** - AnythingLLM chat widget included
- 🔒 **Secure Configuration** - Handlebars-based config generation prevents code injection
- 🎨 **Professional Styling** - Pre-configured Prism themes and responsive design
- 📱 **Responsive Design** - Mobile-first approach

## Getting Started

### Prerequisites

- Node.js 18.0 or higher
- npm or yarn

### Installation

Install dependencies using npm ci (recommended for consistency):

```bash
npm ci
```

Or with npm install:

```bash
npm install
```

### Local Development

Start the development server:

```bash
npm start
```

This command starts a local development server and opens your browser. Most changes are reflected live without restarting.

### Build

Build the static site for production:

```bash
npm run build
```

This generates static content into the `build` directory, ready for deployment on any static hosting service.

### Serve Production Build

To test the production build locally:

```bash
npm run serve
```

This serves the build directory on `http://localhost:8000` (default port).

## Configuration Generation

### Overview

The configuration is generated dynamically from a Handlebars template to prevent security vulnerabilities like code injection. This approach ensures all parameters are safely escaped.

### Generate Configuration

Generate `docusaurus.config.js` from the Handlebars template:

```bash
npm run generate-config -- \
  --site-name "My Documentation" \
  --site-id "docs-001" \
  --site-url "https://docs.example.com" \
  --github-repo "owner/repo"
```

### Parameters

All parameters are required:

- `--site-name`: Display name for the site (navbar and footer)
- `--site-id`: Unique identifier (used for analytics and chat widget)
- `--site-url`: Full URL of the deployed site
- `--github-repo`: GitHub repository in `owner/repo` format

### Security

The configuration generation uses Handlebars templating to safely escape all user input. This prevents code injection attacks:

```javascript
// ✅ Safe - Handlebars escapes special characters
const siteName = '{{siteName}}';

// ❌ Unsafe - Direct string interpolation
const siteName = '$SITE_NAME';
```

Special characters in input (quotes, brackets, etc.) are automatically converted to safe HTML entities.

### Template Files

- `docusaurus.config.js.hbs` - Handlebars template with placeholders
- `scripts/generate-config.js` - Configuration generator script
- `docusaurus.config.js` - Generated config (not committed to git)

See `scripts/README.md` for detailed technical documentation.

## Available Commands

| Command | Description |
|---------|-------------|
| `npm ci` | Install exact dependencies from package-lock.json |
| `npm install` | Install dependencies with version flexibility |
| `npm start` | Start development server on port 3000 |
| `npm run build` | Build production site |
| `npm run serve` | Serve production build locally |
| `npm run generate-config` | Generate config from Handlebars template |
| `npm run clear` | Clear cache |
| `npm run swizzle` | Customize Docusaurus components |
| `npm run write-translations` | Extract i18n strings |
| `npm run write-heading-ids` | Generate heading IDs |

## Project Structure

```
.
├── docs/                      # Documentation files (Markdown)
├── src/
│   ├── css/custom.css         # Custom styles
│   └── pages/                 # Custom pages
├── static/                    # Static assets
├── scripts/
│   ├── generate-config.js     # Config generator
│   └── README.md              # Configuration documentation
├── docusaurus.config.js.hbs   # Config template (Handlebars)
├── docusaurus.config.js       # Generated config (git-ignored)
├── package.json               # Dependencies
└── sidebars.js               # Documentation sidebar structure
```

## Deployment

### Google Cloud Run

Use the provided deployment scripts in the function-build-site repository:

```bash
./scripts/trigger-cloud-build.sh \
  --site-id "site-001" \
  --site-name "My Docs" \
  --subdomain "docs" \
  --github-repo "owner/repo"
```

### Local Build

For local testing before deployment:

```bash
./scripts/build-local.sh \
  --site-name "My Docs" \
  --local-dir "./docs" \
  --port 8000
```

## Chat Widget

The template includes an AnythingLLM chat widget configured with:

- Widget source: `https://statics.docusapiens.ai/anythingllm-chat-widget.js`
- API endpoint: `https://api-chat-1010464005360.europe-west1.run.app`
- Site ID: Dynamically set from configuration

To customize, update `docusaurus.config.js.hbs`:

```javascript
scripts: [
  {
    src: 'https://statics.docusapiens.ai/anythingllm-chat-widget.js',
    'data-site-id': siteId,
    async: true,
  },
],
```

## Customization

### Styling

Edit `src/css/custom.css` to customize colors, fonts, and layout.

### Documentation Structure

Modify `sidebars.js` to organize your documentation structure.

### Theme Configuration

Edit `docusaurus.config.js.hbs` to modify:
- Site title, tagline, favicon
- Navbar items and logo
- Footer content
- Prism syntax highlighting theme
- i18n configuration

**Note:** After modifying `.hbs` template, regenerate the config:

```bash
npm run generate-config -- [parameters]
```

## Troubleshooting

### Build Fails

Clear cache and rebuild:

```bash
npm run clear
npm run build
```

### Port Already in Use

Specify a different port:

```bash
PORT=3001 npm start
```

### Markdown Not Found

Ensure markdown files are in the `docs/` directory with `.md` or `.mdx` extension.

## Contributing

When modifying the template:

1. Update `docusaurus.config.js.hbs` (not the generated `.js` file)
2. Keep `scripts/generate-config.js` synchronized with your changes
3. Test configuration generation: `npm run generate-config -- [parameters]`

## License

This template is part of the Docusapiens project.
