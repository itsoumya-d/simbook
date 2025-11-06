#!/usr/bin/env python3
"""
Comprehensive Web Scraper
Downloads all accessible web resources from any specified website
Supports all file types, authentication, rate limiting, and complete offline mirroring
"""

import os
import sys
import json
import time
import logging
import asyncio
import aiohttp
import aiofiles
import base64
import hashlib
import mimetypes
import re
from urllib.parse import urljoin, urlparse, unquote, quote
from urllib.robotparser import RobotFileParser
from pathlib import Path
from datetime import datetime
from typing import Set, Dict, List, Optional, Tuple, Any
import xml.etree.ElementTree as ET
from playwright.async_api import async_playwright
from bs4 import BeautifulSoup
import cssutils
from dataclasses import dataclass
import asyncio
from collections import defaultdict

@dataclass
class DownloadStats:
    """Statistics for downloaded resources"""
    html_files: int = 0
    css_files: int = 0
    js_files: int = 0
    image_files: int = 0
    video_files: int = 0
    audio_files: int = 0
    font_files: int = 0
    json_files: int = 0
    xml_files: int = 0
    other_files: int = 0
    failed_downloads: int = 0
    total_size: int = 0

class ComprehensiveWebScraper:
    def __init__(self, base_url: str, max_depth: int = 3, rate_limit: float = 1.0, 
                 auth_credentials: Optional[Dict] = None, output_dir: str = "website_mirror"):
        self.base_url = base_url
        self.max_depth = max_depth
        self.rate_limit = rate_limit  # seconds between requests
        self.auth_credentials = auth_credentials
        self.domain = urlparse(base_url).netloc
        self.output_dir = Path(output_dir)
        
        # Tracking sets and dictionaries
        self.visited_urls: Set[str] = set()
        self.downloaded_files: Dict[str, str] = {}
        self.failed_downloads: List[Dict] = []
        self.redirect_chains: List[Dict] = []
        self.resource_dependencies: Dict[str, List[str]] = defaultdict(list)
        self.stats = DownloadStats()
        
        # Configuration
        self.robots_parser = None
        self.session = None
        self.browser = None
        self.page = None
        self.semaphore = asyncio.Semaphore(5)  # Limit concurrent downloads
        
        # File type mappings
        self.file_extensions = {
            'html': ['.html', '.htm', '.xhtml', '.shtml'],
            'css': ['.css'],
            'js': ['.js', '.mjs', '.jsx', '.ts', '.tsx'],
            'images': ['.jpg', '.jpeg', '.png', '.gif', '.svg', '.webp', '.ico', '.bmp', '.tiff'],
            'videos': ['.mp4', '.avi', '.mov', '.wmv', '.flv', '.webm', '.mkv', '.m4v'],
            'audio': ['.mp3', '.wav', '.ogg', '.m4a', '.aac', '.flac', '.wma'],
            'fonts': ['.woff', '.woff2', '.ttf', '.otf', '.eot'],
            'json': ['.json', '.jsonp'],
            'xml': ['.xml', '.rss', '.atom', '.sitemap'],
            'documents': ['.pdf', '.doc', '.docx', '.txt', '.rtf'],
            'archives': ['.zip', '.rar', '.tar', '.gz', '.7z']
        }
        
        # Setup logging and output directory
        self.setup_logging()
        self.output_dir.mkdir(exist_ok=True)
        
    def setup_logging(self):
        """Setup comprehensive logging system"""
        log_format = '%(asctime)s - %(levelname)s - %(message)s'
        logging.basicConfig(
            level=logging.INFO,
            format=log_format,
            handlers=[
                logging.FileHandler(self.output_dir / 'scraping_log.txt'),
                logging.StreamHandler(sys.stdout)
            ]
        )
        self.logger = logging.getLogger(__name__)
        
    async def initialize(self):
        """Initialize browser and HTTP session with authentication"""
        self.logger.info("Initializing comprehensive web scraper...")
        
        # Initialize Playwright browser
        self.playwright = await async_playwright().start()
        self.browser = await self.playwright.chromium.launch(
            headless=True,
            args=['--no-sandbox', '--disable-dev-shm-usage']
        )
        
        # Create browser context with authentication if provided
        context_options = {
            'user_agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
        
        if self.auth_credentials:
            if 'username' in self.auth_credentials and 'password' in self.auth_credentials:
                context_options['http_credentials'] = {
                    'username': self.auth_credentials['username'],
                    'password': self.auth_credentials['password']
                }
        
        self.context = await self.browser.new_context(**context_options)
        self.page = await self.context.new_page()
        
        # Initialize aiohttp session with authentication
        connector = aiohttp.TCPConnector(limit=10, limit_per_host=3)
        timeout = aiohttp.ClientTimeout(total=30)
        
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        
        auth = None
        if self.auth_credentials and 'username' in self.auth_credentials:
            auth = aiohttp.BasicAuth(
                self.auth_credentials['username'],
                self.auth_credentials['password']
            )
        
        self.session = aiohttp.ClientSession(
            connector=connector,
            timeout=timeout,
            headers=headers,
            auth=auth
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
                    # Simple robots.txt compliance check
                    self.robots_rules = self.parse_robots_content(robots_content)
                    self.logger.info("Successfully parsed robots.txt")
                else:
                    self.robots_rules = {}
                    self.logger.warning(f"Could not fetch robots.txt: {response.status}")
        except Exception as e:
            self.logger.warning(f"Error parsing robots.txt: {e}")
            self.robots_rules = {}
            
    def parse_robots_content(self, content: str) -> Dict:
        """Parse robots.txt content manually"""
        rules = {'disallow': [], 'allow': [], 'crawl_delay': 1}
        current_user_agent = None
        
        for line in content.split('\n'):
            line = line.strip().lower()
            if line.startswith('user-agent:'):
                current_user_agent = line.split(':', 1)[1].strip()
            elif line.startswith('disallow:') and current_user_agent in ['*', 'mozilla']:
                path = line.split(':', 1)[1].strip()
                if path:
                    rules['disallow'].append(path)
            elif line.startswith('allow:') and current_user_agent in ['*', 'mozilla']:
                path = line.split(':', 1)[1].strip()
                if path:
                    rules['allow'].append(path)
            elif line.startswith('crawl-delay:'):
                try:
                    rules['crawl_delay'] = float(line.split(':', 1)[1].strip())
                except:
                    pass
                    
        return rules
        
    def can_fetch(self, url: str) -> bool:
        """Check if URL can be fetched according to robots.txt"""
        if not hasattr(self, 'robots_rules'):
            return True
            
        path = urlparse(url).path
        
        # Check disallow rules
        for disallow_path in self.robots_rules.get('disallow', []):
            if path.startswith(disallow_path):
                return False
                
        return True
        
    def is_valid_url(self, url: str) -> bool:
        """Validate URL and check if it belongs to the target domain"""
        try:
            parsed = urlparse(url)
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
            
    def get_file_type(self, url: str, content_type: str = None) -> str:
        """Determine file type based on URL and content type"""
        parsed_url = urlparse(url)
        path = parsed_url.path.lower()
        
        # Check by file extension
        for file_type, extensions in self.file_extensions.items():
            if any(path.endswith(ext) for ext in extensions):
                return file_type
                
        # Check by content type
        if content_type:
            content_type = content_type.lower()
            if 'text/html' in content_type:
                return 'html'
            elif 'text/css' in content_type:
                return 'css'
            elif 'javascript' in content_type or 'application/json' in content_type:
                return 'js' if 'javascript' in content_type else 'json'
            elif 'image/' in content_type:
                return 'images'
            elif 'video/' in content_type:
                return 'videos'
            elif 'audio/' in content_type:
                return 'audio'
            elif 'font/' in content_type or 'application/font' in content_type:
                return 'fonts'
                
        # Default to other if no match
        return 'other'
        
    def get_file_path(self, url: str, content_type: str = None) -> Path:
        """Generate local file path preserving URL structure"""
        parsed = urlparse(url)
        path = unquote(parsed.path)
        
        # Handle root path
        if path == '/' or path == '':
            path = '/index.html'
        elif not Path(path).suffix and not path.endswith('/'):
            # Add appropriate extension based on content type
            file_type = self.get_file_type(url, content_type)
            if file_type == 'html':
                path += '/index.html'
            elif file_type == 'css':
                path += '.css'
            elif file_type == 'js':
                path += '.js'
            elif file_type == 'json':
                path += '.json'
        elif path.endswith('/'):
            path += 'index.html'
            
        # Remove leading slash and create path
        relative_path = path.lstrip('/')
        return self.output_dir / relative_path
        
    async def rate_limit_delay(self):
        """Implement rate limiting"""
        if hasattr(self, 'robots_rules') and 'crawl_delay' in self.robots_rules:
            delay = max(self.rate_limit, self.robots_rules['crawl_delay'])
        else:
            delay = self.rate_limit
        await asyncio.sleep(delay)
        
    async def download_resource(self, url: str, retries: int = 2) -> Optional[str]:
        """Download individual resource with comprehensive error handling"""
        async with self.semaphore:
            if url in self.visited_urls:
                return self.downloaded_files.get(url)
                
            self.visited_urls.add(url)
            
            # Rate limiting
            await self.rate_limit_delay()
            
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
                                return await self.download_resource(redirect_url, retries)
                                
                        # Skip protected resources
                        if response.status in [401, 403]:
                            self.logger.warning(f"Skipping protected resource: {url} (Status: {response.status})")
                            self.failed_downloads.append({
                                'url': url,
                                'reason': f'Protected resource (HTTP {response.status})',
                                'timestamp': datetime.now().isoformat()
                            })
                            self.stats.failed_downloads += 1
                            return None
                            
                        if response.status == 200:
                            content = await response.read()
                            content_type = response.headers.get('content-type', '')
                            file_path = self.get_file_path(url, content_type)
                            
                            # Create directory structure
                            file_path.parent.mkdir(parents=True, exist_ok=True)
                            
                            # Write file
                            async with aiofiles.open(file_path, 'wb') as f:
                                await f.write(content)
                                
                            # Update statistics
                            file_type = self.get_file_type(url, content_type)
                            setattr(self.stats, f"{file_type}_files", 
                                   getattr(self.stats, f"{file_type}_files", 0) + 1)
                            self.stats.total_size += len(content)
                            
                            self.downloaded_files[url] = str(file_path)
                            self.logger.info(f"Downloaded {file_type}: {url} -> {file_path}")
                            
                            # Save HTTP headers and metadata
                            await self.save_metadata(file_path, response.headers, content_type, url)
                            
                            # Extract dependencies for certain file types
                            if file_type in ['html', 'css']:
                                await self.extract_dependencies(url, content, content_type)
                                
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
            self.stats.failed_downloads += 1
            return None
            
    async def save_metadata(self, file_path: Path, headers: Dict, content_type: str, url: str):
        """Save metadata for downloaded files"""
        metadata = {
            'url': url,
            'content_type': content_type,
            'headers': dict(headers),
            'download_time': datetime.now().isoformat(),
            'file_size': file_path.stat().st_size if file_path.exists() else 0
        }
        
        metadata_file = file_path.with_suffix(file_path.suffix + '.metadata')
        async with aiofiles.open(metadata_file, 'w') as f:
            await f.write(json.dumps(metadata, indent=2))
            
    async def extract_dependencies(self, url: str, content: bytes, content_type: str):
        """Extract dependencies from HTML and CSS files"""
        try:
            text_content = content.decode('utf-8', errors='ignore')
            
            if 'text/html' in content_type:
                await self.extract_html_dependencies(url, text_content)
            elif 'text/css' in content_type:
                await self.extract_css_dependencies(url, text_content)
                
        except Exception as e:
            self.logger.error(f"Error extracting dependencies from {url}: {e}")
            
    async def extract_html_dependencies(self, url: str, html_content: str):
        """Extract all dependencies from HTML content"""
        soup = BeautifulSoup(html_content, 'html.parser')
        dependencies = []
        
        # CSS files
        for link in soup.find_all('link', rel='stylesheet'):
            href = link.get('href')
            if href:
                abs_url = urljoin(url, href)
                if self.is_valid_url(abs_url):
                    dependencies.append(abs_url)
                    
        # JavaScript files
        for script in soup.find_all('script', src=True):
            src = script.get('src')
            if src:
                abs_url = urljoin(url, src)
                if self.is_valid_url(abs_url):
                    dependencies.append(abs_url)
                    
        # Images
        for img in soup.find_all('img', src=True):
            src = img.get('src')
            if src:
                abs_url = urljoin(url, src)
                if self.is_valid_url(abs_url):
                    dependencies.append(abs_url)
                    
        # Videos
        for video in soup.find_all(['video', 'source'], src=True):
            src = video.get('src')
            if src:
                abs_url = urljoin(url, src)
                if self.is_valid_url(abs_url):
                    dependencies.append(abs_url)
                    
        # Audio
        for audio in soup.find_all(['audio', 'source'], src=True):
            src = audio.get('src')
            if src:
                abs_url = urljoin(url, src)
                if self.is_valid_url(abs_url):
                    dependencies.append(abs_url)
                    
        # Favicons and icons
        for link in soup.find_all('link', rel=['icon', 'shortcut icon', 'apple-touch-icon']):
            href = link.get('href')
            if href:
                abs_url = urljoin(url, href)
                if self.is_valid_url(abs_url):
                    dependencies.append(abs_url)
                    
        # Manifest files
        for link in soup.find_all('link', rel='manifest'):
            href = link.get('href')
            if href:
                abs_url = urljoin(url, href)
                if self.is_valid_url(abs_url):
                    dependencies.append(abs_url)
                    
        # Extract inline CSS background images
        style_tags = soup.find_all('style')
        for style in style_tags:
            if style.string:
                css_urls = self.extract_css_urls(style.string, url)
                dependencies.extend(css_urls)
                
        # Extract style attribute background images
        for element in soup.find_all(style=True):
            style_content = element.get('style', '')
            css_urls = self.extract_css_urls(style_content, url)
            dependencies.extend(css_urls)
            
        self.resource_dependencies[url] = dependencies
        
        # Download dependencies
        tasks = [self.download_resource(dep_url) for dep_url in dependencies]
        await asyncio.gather(*tasks, return_exceptions=True)
        
    async def extract_css_dependencies(self, url: str, css_content: str):
        """Extract dependencies from CSS content"""
        dependencies = self.extract_css_urls(css_content, url)
        self.resource_dependencies[url] = dependencies
        
        # Download dependencies
        tasks = [self.download_resource(dep_url) for dep_url in dependencies]
        await asyncio.gather(*tasks, return_exceptions=True)
        
    def extract_css_urls(self, css_content: str, base_url: str) -> List[str]:
        """Extract URLs from CSS content"""
        urls = []
        
        # Find all url() declarations
        url_pattern = r'url\s*\(\s*["\']?([^"\')\s]+)["\']?\s*\)'
        matches = re.findall(url_pattern, css_content, re.IGNORECASE)
        
        for match in matches:
            abs_url = urljoin(base_url, match)
            if self.is_valid_url(abs_url):
                urls.append(abs_url)
                
        # Find @import statements
        import_pattern = r'@import\s+["\']([^"\']+)["\']'
        import_matches = re.findall(import_pattern, css_content, re.IGNORECASE)
        
        for match in import_matches:
            abs_url = urljoin(base_url, match)
            if self.is_valid_url(abs_url):
                urls.append(abs_url)
                
        return urls
        
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
                        
            # Extract form actions
            form_elements = await self.page.query_selector_all('form[action]')
            for element in form_elements:
                action = await element.get_attribute('action')
                if action:
                    absolute_url = urljoin(url, action)
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
        await self.download_resource(start_url)
        
        # Extract all links from the page
        links = await self.extract_links_from_page(start_url)
        
        # Recursively crawl page links
        if current_depth < self.max_depth:
            tasks = []
            for link in links:
                # Only crawl HTML pages recursively
                if not any(link.lower().endswith(ext) for ext_list in self.file_extensions.values() for ext in ext_list if ext not in ['.html', '.htm']):
                    tasks.append(self.crawl_recursive(link, current_depth + 1))
                    
            await asyncio.gather(*tasks, return_exceptions=True)
            
    async def download_special_files(self):
        """Download special files like sitemap, robots.txt, manifest, etc."""
        special_files = [
            '/robots.txt',
            '/sitemap.xml',
            '/sitemap.txt',
            '/manifest.json',
            '/favicon.ico',
            '/apple-touch-icon.png',
            '/browserconfig.xml',
            '/.well-known/security.txt'
        ]
        
        tasks = []
        for file_path in special_files:
            url = urljoin(self.base_url, file_path)
            tasks.append(self.download_resource(url))
            
        await asyncio.gather(*tasks, return_exceptions=True)
        
    async def generate_sitemap(self):
        """Generate sitemap.xml of downloaded structure"""
        root = ET.Element("urlset")
        root.set("xmlns", "http://www.sitemaps.org/schemas/sitemap/0.9")
        
        for url in self.downloaded_files.keys():
            if any(url.endswith(ext) for ext in ['.html', '.htm']) or '.' not in urlparse(url).path.split('/')[-1]:
                url_elem = ET.SubElement(root, "url")
                loc_elem = ET.SubElement(url_elem, "loc")
                loc_elem.text = url
                lastmod_elem = ET.SubElement(url_elem, "lastmod")
                lastmod_elem.text = datetime.now().strftime('%Y-%m-%d')
                
        tree = ET.ElementTree(root)
        sitemap_path = self.output_dir / "generated_sitemap.xml"
        tree.write(sitemap_path, encoding='utf-8', xml_declaration=True)
        self.logger.info(f"Generated sitemap: {sitemap_path}")
        
    async def generate_reports(self):
        """Generate comprehensive reports"""
        # Statistics report
        stats_report = {
            'scraping_summary': {
                'start_time': datetime.now().isoformat(),
                'base_url': self.base_url,
                'max_depth': self.max_depth,
                'total_urls_visited': len(self.visited_urls),
                'successful_downloads': len(self.downloaded_files),
                'failed_downloads': len(self.failed_downloads),
                'redirect_chains': len(self.redirect_chains)
            },
            'file_statistics': {
                'html_files': self.stats.html_files,
                'css_files': self.stats.css_files,
                'js_files': self.stats.js_files,
                'image_files': self.stats.image_files,
                'video_files': self.stats.video_files,
                'audio_files': self.stats.audio_files,
                'font_files': self.stats.font_files,
                'json_files': self.stats.json_files,
                'xml_files': self.stats.xml_files,
                'other_files': self.stats.other_files,
                'total_size_bytes': self.stats.total_size,
                'total_size_mb': round(self.stats.total_size / (1024 * 1024), 2)
            },
            'downloaded_files': self.downloaded_files,
            'failed_downloads': self.failed_downloads,
            'redirect_chains': self.redirect_chains,
            'resource_dependencies': dict(self.resource_dependencies)
        }
        
        # Save comprehensive report
        report_path = self.output_dir / "comprehensive_scraping_report.json"
        async with aiofiles.open(report_path, 'w') as f:
            await f.write(json.dumps(stats_report, indent=2))
            
        self.logger.info(f"Comprehensive report saved to: {report_path}")
        
        # Generate dependency graph
        await self.generate_dependency_graph()
        
    async def generate_dependency_graph(self):
        """Generate a dependency graph of all resources"""
        graph = {
            'nodes': [],
            'edges': []
        }
        
        # Add nodes
        for url in self.downloaded_files.keys():
            file_type = self.get_file_type(url)
            graph['nodes'].append({
                'id': url,
                'type': file_type,
                'local_path': self.downloaded_files[url]
            })
            
        # Add edges (dependencies)
        for source_url, dependencies in self.resource_dependencies.items():
            for dep_url in dependencies:
                if dep_url in self.downloaded_files:
                    graph['edges'].append({
                        'source': source_url,
                        'target': dep_url
                    })
                    
        # Save dependency graph
        graph_path = self.output_dir / "dependency_graph.json"
        async with aiofiles.open(graph_path, 'w') as f:
            await f.write(json.dumps(graph, indent=2))
            
        self.logger.info(f"Dependency graph saved to: {graph_path}")
        
    async def cleanup(self):
        """Cleanup resources"""
        if self.session:
            await self.session.close()
        if self.context:
            await self.context.close()
        if self.browser:
            await self.browser.close()
        if self.playwright:
            await self.playwright.stop()
            
    async def run(self):
        """Main execution method"""
        try:
            await self.initialize()
            self.logger.info(f"Starting comprehensive scrape of {self.base_url}")
            
            # Download special files first
            await self.download_special_files()
            
            # Start crawling from base URL
            await self.crawl_recursive(self.base_url)
            
            # Generate sitemap
            await self.generate_sitemap()
            
            # Generate comprehensive reports
            await self.generate_reports()
            
            self.logger.info("Scraping completed successfully!")
            self.logger.info(f"Downloaded {len(self.downloaded_files)} files")
            self.logger.info(f"Total size: {self.stats.total_size_mb} MB")
            self.logger.info(f"Failed downloads: {len(self.failed_downloads)}")
            
            return {
                'success': True,
                'total_files': len(self.downloaded_files),
                'total_size_mb': round(self.stats.total_size / (1024 * 1024), 2),
                'failed_downloads': len(self.failed_downloads)
            }
            
        except Exception as e:
            self.logger.error(f"Scraping failed: {e}")
            raise
        finally:
            await self.cleanup()

async def main():
    """Main entry point with configuration options"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Comprehensive Web Scraper')
    parser.add_argument('url', help='Base URL to scrape')
    parser.add_argument('--depth', type=int, default=3, help='Maximum crawling depth')
    parser.add_argument('--rate-limit', type=float, default=1.0, help='Rate limit in seconds')
    parser.add_argument('--output', default='website_mirror', help='Output directory')
    parser.add_argument('--username', help='Username for authentication')
    parser.add_argument('--password', help='Password for authentication')
    
    args = parser.parse_args()
    
    # Setup authentication if provided
    auth_credentials = None
    if args.username and args.password:
        auth_credentials = {
            'username': args.username,
            'password': args.password
        }
    
    # Create and run scraper
    scraper = ComprehensiveWebScraper(
        base_url=args.url,
        max_depth=args.depth,
        rate_limit=args.rate_limit,
        auth_credentials=auth_credentials,
        output_dir=args.output
    )
    
    try:
        result = await scraper.run()
        print(f"\n✅ Scraping completed successfully!")
        print(f"📁 Output directory: {args.output}")
        print(f"📄 Total files: {result['total_files']}")
        print(f"💾 Total size: {result['total_size_mb']} MB")
        if result['failed_downloads'] > 0:
            print(f"⚠️  Failed downloads: {result['failed_downloads']}")
    except KeyboardInterrupt:
        print("\n❌ Scraping interrupted by user")
    except Exception as e:
        print(f"❌ Scraping failed: {e}")

if __name__ == "__main__":
    asyncio.run(main())