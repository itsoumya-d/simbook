#!/usr/bin/env python3
"""
SoBrief.com Frontend Resource Downloader
Comprehensive web scraper with JavaScript rendering support
"""

import os
import sys
import json
import time
import logging
import asyncio
import aiohttp
import aiofiles
from urllib.parse import urljoin, urlparse, unquote
from urllib.robotparser import RobotFileParser
from pathlib import Path
from datetime import datetime
from typing import Set, Dict, List, Optional, Tuple
import xml.etree.ElementTree as ET
from playwright.async_api import async_playwright
import hashlib
import mimetypes

class SoBriefScraper:
    def __init__(self, base_url: str = "https://sobrief.com", max_depth: int = 3):
        self.base_url = base_url
        self.max_depth = max_depth
        self.domain = urlparse(base_url).netloc
        self.output_dir = Path("sobrief_frontend")
        self.visited_urls: Set[str] = set()
        self.downloaded_files: Dict[str, str] = {}
        self.failed_downloads: List[Dict] = []
        self.redirect_chains: List[Dict] = []
        self.robots_parser = None
        self.session = None
        self.browser = None
        self.page = None
        
        # Setup logging
        self.setup_logging()
        
        # Create output directory
        self.output_dir.mkdir(exist_ok=True)
        
    def setup_logging(self):
        """Setup comprehensive logging system"""
        log_format = '%(asctime)s - %(levelname)s - %(message)s'
        logging.basicConfig(
            level=logging.INFO,
            format=log_format,
            handlers=[
                logging.FileHandler(self.output_dir / 'download_log.txt'),
                logging.StreamHandler(sys.stdout)
            ]
        )
        self.logger = logging.getLogger(__name__)
        
    async def initialize(self):
        """Initialize browser and HTTP session"""
        self.logger.info("Initializing browser and HTTP session...")
        
        # Initialize Playwright browser
        self.playwright = await async_playwright().start()
        self.browser = await self.playwright.chromium.launch(headless=True)
        self.page = await self.browser.new_page()
        
        # Set user agent and headers
        await self.page.set_extra_http_headers({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })
        
        # Initialize aiohttp session
        connector = aiohttp.TCPConnector(limit=10, limit_per_host=5)
        timeout = aiohttp.ClientTimeout(total=30)
        self.session = aiohttp.ClientSession(
            connector=connector,
            timeout=timeout,
            headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
        )
        
        # Parse robots.txt
        await self.parse_robots_txt()
        
    async def parse_robots_txt(self):
        """Parse and respect robots.txt directives"""
        try:
            robots_url = urljoin(self.base_url, '/robots.txt')
            async with self.session.get(robots_url) as response:
                if response.status == 200:
                    robots_content = await response.text()
                    self.robots_parser = RobotFileParser()
                    self.robots_parser.set_url(robots_url)
                    # Parse the content using the correct method
                    import io
                    robots_file = io.StringIO(robots_content)
                    self.robots_parser.read(robots_file)
                    self.logger.info("Successfully parsed robots.txt")
                else:
                    self.logger.warning(f"Could not fetch robots.txt: {response.status}")
        except Exception as e:
            self.logger.warning(f"Error parsing robots.txt: {e}")
            # Create a permissive robots parser if parsing fails
            self.robots_parser = None
            
    def can_fetch(self, url: str) -> bool:
        """Check if URL can be fetched according to robots.txt"""
        if self.robots_parser:
            return self.robots_parser.can_fetch('*', url)
        return True
        
    def is_valid_url(self, url: str) -> bool:
        """Validate URL and check if it belongs to the target domain"""
        try:
            parsed = urlparse(url)
            # Handle both www and non-www versions
            domain_match = (
                parsed.netloc == self.domain or
                parsed.netloc == f"www.{self.domain}" or
                parsed.netloc == self.domain.replace("www.", "")
            )
            return (
                domain_match and
                parsed.scheme in ['http', 'https'] and
                self.can_fetch(url)
            )
        except:
            return False
            
    def get_file_path(self, url: str) -> Path:
        """Generate local file path preserving URL structure"""
        parsed = urlparse(url)
        path = unquote(parsed.path)
        
        if path == '/' or path == '':
            path = '/index.html'
        elif not Path(path).suffix and not path.endswith('/'):
            path += '/index.html'
        elif path.endswith('/'):
            path += 'index.html'
            
        # Remove leading slash and create path
        relative_path = path.lstrip('/')
        return self.output_dir / relative_path
        
    async def download_asset(self, url: str, retries: int = 2) -> Optional[str]:
        """Download individual asset with retry logic"""
        if url in self.visited_urls:
            return self.downloaded_files.get(url)
            
        self.visited_urls.add(url)
        
        for attempt in range(retries + 1):
            try:
                async with self.session.get(url) as response:
                    # Handle redirects
                    if response.status in [301, 302, 303, 307, 308]:
                        redirect_url = str(response.url)
                        self.redirect_chains.append({
                            'original': url,
                            'redirect': redirect_url,
                            'status': response.status
                        })
                        if self.is_valid_url(redirect_url):
                            return await self.download_asset(redirect_url, retries)
                        
                    # Skip protected resources
                    if response.status in [401, 403]:
                        self.logger.warning(f"Skipping protected resource: {url} (Status: {response.status})")
                        self.failed_downloads.append({
                            'url': url,
                            'reason': f'Protected resource (HTTP {response.status})',
                            'timestamp': datetime.now().isoformat()
                        })
                        return None
                        
                    # Check for no-archive headers
                    if 'no-archive' in response.headers.get('Cache-Control', '').lower():
                        self.logger.warning(f"Skipping no-archive resource: {url}")
                        self.failed_downloads.append({
                            'url': url,
                            'reason': 'No-archive directive',
                            'timestamp': datetime.now().isoformat()
                        })
                        return None
                        
                    if response.status == 200:
                        content = await response.read()
                        file_path = self.get_file_path(url)
                        
                        # Create directory structure
                        file_path.parent.mkdir(parents=True, exist_ok=True)
                        
                        # Write file
                        async with aiofiles.open(file_path, 'wb') as f:
                            await f.write(content)
                            
                        self.downloaded_files[url] = str(file_path)
                        self.logger.info(f"Downloaded: {url} -> {file_path}")
                        
                        # Save HTTP headers
                        headers_file = file_path.with_suffix(file_path.suffix + '.headers')
                        async with aiofiles.open(headers_file, 'w') as f:
                            await f.write(json.dumps(dict(response.headers), indent=2))
                            
                        return str(file_path)
                    else:
                        self.logger.warning(f"Failed to download {url}: HTTP {response.status}")
                        
            except asyncio.TimeoutError:
                self.logger.warning(f"Timeout downloading {url} (attempt {attempt + 1})")
            except Exception as e:
                self.logger.error(f"Error downloading {url} (attempt {attempt + 1}): {e}")
                
        # All retries failed
        self.failed_downloads.append({
            'url': url,
            'reason': 'Max retries exceeded',
            'timestamp': datetime.now().isoformat()
        })
        return None
        
    async def extract_links_from_page(self, url: str) -> Set[str]:
        """Extract all links from a page using Playwright for JS rendering"""
        links = set()
        
        try:
            # Navigate to page
            await self.page.goto(url, wait_until='networkidle', timeout=30000)
            
            # Wait for dynamic content
            await self.page.wait_for_timeout(2000)
            
            # Extract all links
            link_elements = await self.page.query_selector_all('a[href]')
            for element in link_elements:
                href = await element.get_attribute('href')
                if href:
                    absolute_url = urljoin(url, href)
                    if self.is_valid_url(absolute_url):
                        links.add(absolute_url)
                        
            # Extract CSS links
            css_elements = await self.page.query_selector_all('link[rel="stylesheet"]')
            for element in css_elements:
                href = await element.get_attribute('href')
                if href:
                    absolute_url = urljoin(url, href)
                    if self.is_valid_url(absolute_url):
                        links.add(absolute_url)
                        
            # Extract JavaScript files
            js_elements = await self.page.query_selector_all('script[src]')
            for element in js_elements:
                src = await element.get_attribute('src')
                if src:
                    absolute_url = urljoin(url, src)
                    if self.is_valid_url(absolute_url):
                        links.add(absolute_url)
                        
            # Extract images
            img_elements = await self.page.query_selector_all('img[src]')
            for element in img_elements:
                src = await element.get_attribute('src')
                if src:
                    absolute_url = urljoin(url, src)
                    if self.is_valid_url(absolute_url):
                        links.add(absolute_url)
                        
            # Extract background images from CSS
            bg_images = await self.page.evaluate("""
                () => {
                    const images = [];
                    const elements = document.querySelectorAll('*');
                    elements.forEach(el => {
                        const style = window.getComputedStyle(el);
                        const bgImage = style.backgroundImage;
                        if (bgImage && bgImage !== 'none') {
                            const matches = bgImage.match(/url\\(["']?([^"')]+)["']?\\)/g);
                            if (matches) {
                                matches.forEach(match => {
                                    const url = match.replace(/url\\(["']?([^"')]+)["']?\\)/, '$1');
                                    images.push(url);
                                });
                            }
                        }
                    });
                    return images;
                }
            """)
            
            for img_url in bg_images:
                absolute_url = urljoin(url, img_url)
                if self.is_valid_url(absolute_url):
                    links.add(absolute_url)
                    
        except Exception as e:
            self.logger.error(f"Error extracting links from {url}: {e}")
            
        return links
        
    async def crawl_recursive(self, start_url: str, current_depth: int = 0) -> None:
        """Recursively crawl website up to specified depth"""
        if current_depth > self.max_depth or start_url in self.visited_urls:
            return
            
        self.logger.info(f"Crawling depth {current_depth}: {start_url}")
        
        # Download the main page
        await self.download_asset(start_url)
        
        # Extract all links from the page
        links = await self.extract_links_from_page(start_url)
        
        # Download all assets found on this page
        asset_tasks = []
        page_links = []
        
        for link in links:
            parsed = urlparse(link)
            path = parsed.path.lower()
            
            # Categorize links
            if any(path.endswith(ext) for ext in ['.css', '.js', '.png', '.jpg', '.jpeg', '.gif', '.svg', '.ico', '.woff', '.woff2', '.ttf', '.eot']):
                # Static assets - download immediately
                asset_tasks.append(self.download_asset(link))
            elif current_depth < self.max_depth:
                # HTML pages - crawl recursively
                page_links.append(link)
                
        # Download all assets concurrently
        if asset_tasks:
            await asyncio.gather(*asset_tasks, return_exceptions=True)
            
        # Recursively crawl page links
        for link in page_links:
            await self.crawl_recursive(link, current_depth + 1)
            
    async def generate_sitemap(self):
        """Generate sitemap.xml of downloaded structure"""
        root = ET.Element("urlset")
        root.set("xmlns", "http://www.sitemaps.org/schemas/sitemap/0.9")
        
        for url in self.downloaded_files.keys():
            if url.endswith(('.html', '.htm')) or '.' not in urlparse(url).path.split('/')[-1]:
                url_elem = ET.SubElement(root, "url")
                loc_elem = ET.SubElement(url_elem, "loc")
                loc_elem.text = url
                lastmod_elem = ET.SubElement(url_elem, "lastmod")
                lastmod_elem.text = datetime.now().strftime('%Y-%m-%d')
                
        tree = ET.ElementTree(root)
        sitemap_path = self.output_dir / "sitemap.xml"
        tree.write(sitemap_path, encoding='utf-8', xml_declaration=True)
        self.logger.info(f"Generated sitemap: {sitemap_path}")
        
    async def validate_downloads(self):
        """Validate downloaded content integrity"""
        self.logger.info("Validating downloaded content...")
        
        validation_report = {
            'total_files': len(self.downloaded_files),
            'html_files': 0,
            'css_files': 0,
            'js_files': 0,
            'image_files': 0,
            'other_files': 0,
            'broken_links': []
        }
        
        for url, file_path in self.downloaded_files.items():
            if not Path(file_path).exists():
                validation_report['broken_links'].append(f"Missing file: {file_path}")
                continue
                
            file_ext = Path(file_path).suffix.lower()
            if file_ext in ['.html', '.htm']:
                validation_report['html_files'] += 1
            elif file_ext == '.css':
                validation_report['css_files'] += 1
            elif file_ext == '.js':
                validation_report['js_files'] += 1
            elif file_ext in ['.png', '.jpg', '.jpeg', '.gif', '.svg', '.ico']:
                validation_report['image_files'] += 1
            else:
                validation_report['other_files'] += 1
                
        # Save validation report
        report_path = self.output_dir / "validation_report.json"
        async with aiofiles.open(report_path, 'w') as f:
            await f.write(json.dumps(validation_report, indent=2))
            
        self.logger.info(f"Validation complete. Report saved to: {report_path}")
        return validation_report
        
    async def generate_final_report(self):
        """Generate comprehensive final report"""
        report = {
            'scraping_summary': {
                'start_time': datetime.now().isoformat(),
                'base_url': self.base_url,
                'max_depth': self.max_depth,
                'total_urls_visited': len(self.visited_urls),
                'successful_downloads': len(self.downloaded_files),
                'failed_downloads': len(self.failed_downloads),
                'redirect_chains': len(self.redirect_chains)
            },
            'downloaded_files': self.downloaded_files,
            'failed_downloads': self.failed_downloads,
            'redirect_chains': self.redirect_chains
        }
        
        report_path = self.output_dir / "scraping_report.json"
        async with aiofiles.open(report_path, 'w') as f:
            await f.write(json.dumps(report, indent=2))
            
        self.logger.info(f"Final report saved to: {report_path}")
        
    async def cleanup(self):
        """Cleanup resources"""
        if self.session:
            await self.session.close()
        if self.browser:
            await self.browser.close()
        if self.playwright:
            await self.playwright.stop()
            
    async def run(self):
        """Main execution method"""
        try:
            await self.initialize()
            self.logger.info(f"Starting comprehensive scrape of {self.base_url}")
            
            # Start crawling from base URL
            await self.crawl_recursive(self.base_url)
            
            # Generate sitemap
            await self.generate_sitemap()
            
            # Validate downloads
            validation_report = await self.validate_downloads()
            
            # Generate final report
            await self.generate_final_report()
            
            self.logger.info("Scraping completed successfully!")
            self.logger.info(f"Downloaded {len(self.downloaded_files)} files")
            self.logger.info(f"Failed downloads: {len(self.failed_downloads)}")
            
            return validation_report
            
        except Exception as e:
            self.logger.error(f"Scraping failed: {e}")
            raise
        finally:
            await self.cleanup()

async def main():
    """Main entry point"""
    scraper = SoBriefScraper()
    try:
        await scraper.run()
    except KeyboardInterrupt:
        print("\nScraping interrupted by user")
    except Exception as e:
        print(f"Scraping failed: {e}")

if __name__ == "__main__":
    asyncio.run(main())