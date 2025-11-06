# SoBrief.com Frontend Resource Downloader

A comprehensive web scraper designed to download all publicly accessible frontend resources from SoBrief.com while respecting robots.txt directives and implementing robust error handling.

## Features

### 🎯 Comprehensive Scope
- Downloads primary HTML pages and all directly linked resources (CSS, JavaScript)
- Captures static assets including images, icons, fonts (only if publicly accessible)
- Analyzes navigation links through sitemap discovery
- Processes JavaScript-rendered pages and their associated assets

### 🕷️ Advanced Crawling
- Recursive link following up to depth level 3
- JavaScript-based navigation processing for dynamic routes
- Respects robots.txt directives and HTTP headers (no-archive, no-cache)
- Maintains original folder hierarchy and URL path structure

### 🔧 Technical Capabilities
- Saves content in organized "sobrief_frontend" folder structure
- Preserves original filenames and extensions
- Includes HTTP headers with each asset request
- Generates comprehensive download logs with detailed status tracking

### 🛡️ Security & Compliance
- Strictly avoids backend code or restricted files
- Skips authentication-protected resources (401/403 status codes)
- Excludes URLs with access restrictions
- No execution of embedded scripts for security

### ✅ Validation & Reporting
- Verifies downloaded HTML pages render correctly
- Ensures CSS/JS dependencies are properly resolved
- Confirms static assets maintain functionality
- Generates sitemap.xml of downloaded structure

### 🔄 Error Handling
- Implements 30-second timeout per request
- Retry mechanism for failed downloads (max 2 attempts)
- Skips malformed URLs automatically
- Handles redirect loops appropriately

## Installation

### Prerequisites
- Python 3.8 or higher
- pip package manager
- Internet connection

### Quick Setup
1. Run the setup script to install all dependencies:
```bash
python setup.py
```

This will:
- Install all required Python packages
- Download and configure Playwright browsers
- Create the output directory structure

### Manual Installation
If you prefer manual setup:

```bash
# Install Python dependencies
pip install -r requirements.txt

# Install Playwright browsers
playwright install chromium

# Create output directory
mkdir sobrief_frontend
```

## Usage

### Basic Usage
Run the scraper with default settings:
```bash
python sobrief_scraper.py
```

### Advanced Configuration
The scraper can be customized by modifying the `SoBriefScraper` class initialization:

```python
# Custom depth and base URL
scraper = SoBriefScraper(
    base_url="https://sobrief.com",
    max_depth=3  # Adjust crawling depth
)
```

## Output Structure

The scraper creates the following organized structure:

```
sobrief_frontend/
├── index.html                 # Main page
├── index.html.headers         # HTTP headers for main page
├── css/                       # Stylesheets
│   ├── main.css
│   └── main.css.headers
├── js/                        # JavaScript files
│   ├── app.js
│   └── app.js.headers
├── images/                    # Image assets
│   ├── logo.png
│   └── logo.png.headers
├── fonts/                     # Font files
├── sitemap.xml               # Generated sitemap
├── download_log.txt          # Detailed download log
├── scraping_report.json      # Comprehensive scraping report
└── validation_report.json    # Content validation results
```

## Generated Reports

### Download Log (`download_log.txt`)
Real-time logging of all scraping activities:
- Successful downloads with timestamps
- Failed downloads with error reasons
- Redirect chains and status codes
- Security constraint violations

### Scraping Report (`scraping_report.json`)
Comprehensive summary including:
```json
{
  "scraping_summary": {
    "start_time": "2024-01-15T10:30:00",
    "base_url": "https://sobrief.com",
    "max_depth": 3,
    "total_urls_visited": 1250,
    "successful_downloads": 1180,
    "failed_downloads": 70,
    "redirect_chains": 25
  },
  "downloaded_files": {...},
  "failed_downloads": [...],
  "redirect_chains": [...]
}
```

### Validation Report (`validation_report.json`)
Content integrity verification:
```json
{
  "total_files": 1180,
  "html_files": 45,
  "css_files": 12,
  "js_files": 28,
  "image_files": 890,
  "other_files": 205,
  "broken_links": []
}
```

## Security Features

### Robots.txt Compliance
- Automatically fetches and parses robots.txt
- Respects all crawl directives
- Logs skipped URLs due to robots.txt restrictions

### HTTP Header Respect
- Honors `no-archive` cache control directives
- Skips resources with access restrictions
- Maintains ethical scraping practices

### Access Control
- Automatically skips 401/403 protected resources
- No authentication attempts
- Respects server-side access controls

## Error Handling

### Timeout Management
- 30-second timeout per request
- Graceful handling of slow responses
- Automatic retry for timeout failures

### Retry Logic
- Maximum 2 retry attempts per failed download
- Exponential backoff between retries
- Detailed logging of retry attempts

### Malformed URL Handling
- Automatic URL validation
- Skips invalid or malformed URLs
- Logs problematic URLs for review

## Performance Optimization

### Concurrent Downloads
- Asynchronous asset downloading
- Configurable connection limits
- Efficient resource utilization

### Memory Management
- Streaming downloads for large files
- Automatic cleanup of resources
- Memory-efficient processing

### Network Optimization
- Connection pooling
- Keep-alive connections
- Optimized request headers

## Troubleshooting

### Common Issues

**Issue**: Playwright browser installation fails
**Solution**: Run `playwright install chromium` manually

**Issue**: Permission denied errors
**Solution**: Ensure write permissions in the current directory

**Issue**: Network timeout errors
**Solution**: Check internet connection and firewall settings

**Issue**: High memory usage
**Solution**: Reduce max_depth or implement pagination

### Debug Mode
Enable verbose logging by modifying the logging level:
```python
logging.basicConfig(level=logging.DEBUG)
```

## Legal Considerations

This scraper is designed for educational and research purposes. Please ensure you:
- Respect the website's terms of service
- Follow robots.txt directives (automatically enforced)
- Use reasonable request rates
- Obtain permission for commercial use

## Contributing

To contribute to this project:
1. Fork the repository
2. Create a feature branch
3. Implement your changes
4. Add appropriate tests
5. Submit a pull request

## License

This project is provided as-is for educational purposes. Please respect the target website's terms of service and copyright policies.

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review the generated log files
3. Examine the validation reports
4. Create an issue with detailed error information