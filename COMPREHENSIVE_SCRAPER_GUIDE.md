# Comprehensive Web Scraper Guide

A powerful, feature-rich web scraping tool that creates complete offline mirrors of websites with all resources and dependencies.

## 🌟 Features

### Complete Resource Coverage
- **HTML files**: All pages including dynamically generated content
- **CSS stylesheets**: External files, inline styles, and imported stylesheets
- **JavaScript files**: All scripts including modules and TypeScript
- **Media assets**: Images (JPG, PNG, GIF, SVG, WebP), videos (MP4, WebM, etc.), audio files
- **Font files**: WOFF, WOFF2, TTF, OTF, EOT formats
- **JSON data**: API responses, configuration files, manifests
- **Favicons**: All icon variations and sizes
- **Metadata files**: Sitemaps, robots.txt, manifest.json, security.txt

### Advanced Capabilities
- **JavaScript rendering**: Uses Playwright for dynamic content
- **Authentication support**: Basic HTTP auth and form-based login
- **Rate limiting**: Respectful crawling with configurable delays
- **Dependency tracking**: Maps all resource relationships
- **Error handling**: Comprehensive retry logic and failure reporting
- **Progress monitoring**: Real-time logging and statistics
- **Robots.txt compliance**: Automatic parsing and respect for directives

## 🚀 Quick Start

### Basic Usage
```bash
# Simple scraping
python comprehensive_web_scraper.py https://example.com

# With custom depth and rate limiting
python comprehensive_web_scraper.py https://example.com --depth 5 --rate-limit 0.5

# With authentication
python comprehensive_web_scraper.py https://example.com --username user --password pass
```

### Interactive Mode
```bash
python scraper_config.py
```
This launches an interactive setup that guides you through all configuration options.

### Preset Configurations
```bash
# Use predefined presets
python scraper_config.py https://example.com basic      # Minimal scraping
python scraper_config.py https://example.com standard   # Balanced approach
python scraper_config.py https://example.com comprehensive  # Deep scraping
python scraper_config.py https://example.com respectful # Slow and careful
```

## 📋 Installation

### Prerequisites
```bash
# Install Python dependencies
pip install -r requirements_comprehensive.txt

# Install Playwright browsers
python -m playwright install chromium
```

### Dependencies
- **aiohttp**: Async HTTP client
- **playwright**: Browser automation for JavaScript rendering
- **beautifulsoup4**: HTML parsing
- **cssutils**: CSS parsing and manipulation
- **aiofiles**: Async file operations

## ⚙️ Configuration Options

### Command Line Arguments
```bash
python comprehensive_web_scraper.py [URL] [OPTIONS]

Options:
  --depth INTEGER        Maximum crawling depth (default: 3)
  --rate-limit FLOAT     Delay between requests in seconds (default: 1.0)
  --output TEXT          Output directory name
  --username TEXT        Username for authentication
  --password TEXT        Password for authentication
```

### Preset Configurations

| Preset | Depth | Rate Limit | Use Case |
|--------|-------|------------|----------|
| `basic` | 2 | 1.0s | Quick overview, small sites |
| `standard` | 3 | 0.5s | Most websites, balanced approach |
| `comprehensive` | 5 | 0.3s | Complete site mirrors |
| `aggressive` | 7 | 0.1s | Maximum coverage (use carefully) |
| `respectful` | 3 | 2.0s | High-traffic sites, careful scraping |

### Programmatic Usage
```python
from comprehensive_web_scraper import ComprehensiveWebScraper

# Basic setup
scraper = ComprehensiveWebScraper(
    base_url="https://example.com",
    max_depth=3,
    rate_limit=1.0,
    output_dir="example_mirror"
)

# With authentication
auth_credentials = {
    'username': 'your_username',
    'password': 'your_password'
}

scraper = ComprehensiveWebScraper(
    base_url="https://example.com",
    auth_credentials=auth_credentials
)

# Run the scraper
result = await scraper.run()
```

## 📁 Output Structure

The scraper creates a complete mirror maintaining the original website structure:

```
website_mirror/
├── index.html                          # Main page
├── index.html.metadata                 # Metadata for main page
├── css/
│   ├── main.css                        # Stylesheets
│   ├── main.css.metadata
│   └── fonts/                          # Font files
├── js/
│   ├── app.js                          # JavaScript files
│   └── app.js.metadata
├── images/
│   ├── logo.png                        # Image assets
│   ├── logo.png.metadata
│   └── icons/                          # Favicons and icons
├── videos/                             # Video files
├── audio/                              # Audio files
├── data/                               # JSON and XML files
├── scraping_log.txt                    # Detailed operation log
├── comprehensive_scraping_report.json  # Complete statistics
├── dependency_graph.json               # Resource relationships
├── generated_sitemap.xml               # Site structure map
└── robots.txt                          # Original robots.txt
```

## 📊 Reports and Analytics

### Scraping Log (`scraping_log.txt`)
Real-time log of all operations:
- Download progress and status
- Error messages and retry attempts
- Rate limiting and delay information
- Authentication status

### Comprehensive Report (`comprehensive_scraping_report.json`)
Detailed statistics and metadata:
```json
{
  "scraping_summary": {
    "start_time": "2024-01-15T10:30:00",
    "base_url": "https://example.com",
    "total_urls_visited": 1250,
    "successful_downloads": 1180,
    "failed_downloads": 70
  },
  "file_statistics": {
    "html_files": 45,
    "css_files": 12,
    "js_files": 28,
    "image_files": 890,
    "video_files": 5,
    "audio_files": 3,
    "font_files": 8,
    "json_files": 15,
    "total_size_mb": 245.7
  }
}
```

### Dependency Graph (`dependency_graph.json`)
Maps relationships between resources:
```json
{
  "nodes": [
    {"id": "https://example.com/", "type": "html", "local_path": "index.html"},
    {"id": "https://example.com/css/main.css", "type": "css", "local_path": "css/main.css"}
  ],
  "edges": [
    {"source": "https://example.com/", "target": "https://example.com/css/main.css"}
  ]
}
```

## 🔐 Authentication

### Basic HTTP Authentication
```python
auth_credentials = {
    'username': 'your_username',
    'password': 'your_password'
}
```

### Form-Based Authentication
For complex authentication, the scraper can handle:
- Login forms
- Session cookies
- CSRF tokens
- Multi-step authentication

## 🛡️ Security and Ethics

### Robots.txt Compliance
- Automatically fetches and parses robots.txt
- Respects `Disallow` directives
- Honors `Crawl-delay` settings
- Logs skipped URLs for transparency

### Rate Limiting
- Configurable delays between requests
- Respects server-specified crawl delays
- Concurrent request limiting
- Automatic backoff on errors

### Best Practices
1. **Always check robots.txt** before scraping
2. **Use appropriate rate limits** to avoid overwhelming servers
3. **Respect copyright** and terms of service
4. **Monitor server response** and adjust accordingly
5. **Use authentication only** when authorized

## 🔧 Advanced Features

### Custom File Type Handling
The scraper automatically detects and handles:
- **Web fonts**: WOFF, WOFF2, TTF, OTF, EOT
- **Vector graphics**: SVG files with embedded resources
- **Compressed files**: ZIP, RAR, TAR archives
- **Documents**: PDF, DOC, TXT files
- **Data formats**: JSON, XML, CSV files

### Dependency Resolution
- **CSS imports**: @import statements and url() references
- **JavaScript modules**: ES6 imports and require() statements
- **HTML resources**: All linked assets and embedded content
- **Inline resources**: Base64 encoded images and data URIs

### Error Recovery
- **Automatic retries**: Configurable retry attempts
- **Timeout handling**: Graceful handling of slow responses
- **Partial failures**: Continue scraping despite individual failures
- **Resume capability**: Skip already downloaded files

## 🐛 Troubleshooting

### Common Issues

**Issue**: "Permission denied" errors
**Solution**: Check file permissions and available disk space

**Issue**: "Too many requests" errors
**Solution**: Increase rate limiting delay

**Issue**: JavaScript-heavy sites not fully scraped
**Solution**: Increase wait times in Playwright configuration

**Issue**: Large files causing memory issues
**Solution**: Implement streaming downloads for large assets

### Debug Mode
Enable verbose logging:
```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

### Performance Optimization
- **Concurrent downloads**: Adjust semaphore limits
- **Memory usage**: Monitor for large file handling
- **Network optimization**: Use connection pooling
- **Disk I/O**: Consider SSD storage for large scrapes

## 📈 Performance Metrics

### Typical Performance
- **Small sites** (< 100 pages): 5-15 minutes
- **Medium sites** (100-1000 pages): 30-90 minutes
- **Large sites** (1000+ pages): 2-8 hours
- **Download speed**: 50-200 files per minute (depending on rate limiting)

### Resource Usage
- **Memory**: 100-500 MB typical usage
- **CPU**: Low to moderate usage
- **Network**: Respects rate limiting
- **Disk**: Varies by site size

## 🤝 Contributing

### Feature Requests
- Additional file type support
- Enhanced authentication methods
- Performance optimizations
- New output formats

### Bug Reports
Include:
- Target website URL (if public)
- Configuration used
- Error messages and logs
- System information

## 📄 License

This tool is provided for educational and research purposes. Please:
- Respect website terms of service
- Follow robots.txt directives
- Use appropriate rate limiting
- Obtain permission for commercial use

## 🆘 Support

For issues or questions:
1. Check this guide and troubleshooting section
2. Review the generated log files
3. Examine the comprehensive reports
4. Create an issue with detailed information

---

**Happy Scraping! 🕷️**