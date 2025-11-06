#!/usr/bin/env python3
"""
Comprehensive Web Scraper Configuration and Runner
Easy-to-use interface for configuring and running the web scraper
"""

import asyncio
import json
from pathlib import Path
from comprehensive_web_scraper import ComprehensiveWebScraper

class ScraperConfig:
    """Configuration manager for the web scraper"""
    
    def __init__(self):
        self.presets = {
            'basic': {
                'max_depth': 2,
                'rate_limit': 1.0,
                'description': 'Basic scraping with minimal depth'
            },
            'standard': {
                'max_depth': 3,
                'rate_limit': 0.5,
                'description': 'Standard scraping for most websites'
            },
            'comprehensive': {
                'max_depth': 5,
                'rate_limit': 0.3,
                'description': 'Deep scraping for complete site mirrors'
            },
            'aggressive': {
                'max_depth': 7,
                'rate_limit': 0.1,
                'description': 'Maximum depth and speed (use carefully)'
            },
            'respectful': {
                'max_depth': 3,
                'rate_limit': 2.0,
                'description': 'Slow and respectful scraping'
            }
        }
        
    def get_preset(self, preset_name: str) -> dict:
        """Get configuration preset"""
        return self.presets.get(preset_name, self.presets['standard'])
        
    def list_presets(self):
        """List all available presets"""
        print("Available presets:")
        for name, config in self.presets.items():
            print(f"  {name}: {config['description']}")
            print(f"    - Max depth: {config['max_depth']}")
            print(f"    - Rate limit: {config['rate_limit']}s")
            print()

async def run_scraper_with_config(
    url: str,
    preset: str = 'standard',
    output_dir: str = None,
    auth_username: str = None,
    auth_password: str = None,
    custom_depth: int = None,
    custom_rate_limit: float = None
):
    """Run scraper with specified configuration"""
    
    config_manager = ScraperConfig()
    preset_config = config_manager.get_preset(preset)
    
    # Override with custom values if provided
    max_depth = custom_depth if custom_depth is not None else preset_config['max_depth']
    rate_limit = custom_rate_limit if custom_rate_limit is not None else preset_config['rate_limit']
    
    # Generate output directory name if not provided
    if output_dir is None:
        from urllib.parse import urlparse
        domain = urlparse(url).netloc.replace('www.', '')
        output_dir = f"{domain}_mirror"
    
    # Setup authentication if provided
    auth_credentials = None
    if auth_username and auth_password:
        auth_credentials = {
            'username': auth_username,
            'password': auth_password
        }
    
    print(f"🚀 Starting scraper with '{preset}' preset")
    print(f"📍 Target URL: {url}")
    print(f"📁 Output directory: {output_dir}")
    print(f"🔍 Max depth: {max_depth}")
    print(f"⏱️  Rate limit: {rate_limit}s")
    if auth_credentials:
        print(f"🔐 Authentication: Enabled")
    print()
    
    # Create and run scraper
    scraper = ComprehensiveWebScraper(
        base_url=url,
        max_depth=max_depth,
        rate_limit=rate_limit,
        auth_credentials=auth_credentials,
        output_dir=output_dir
    )
    
    try:
        result = await scraper.run()
        
        print("\n" + "="*60)
        print("✅ SCRAPING COMPLETED SUCCESSFULLY!")
        print("="*60)
        print(f"📁 Output directory: {output_dir}")
        print(f"📄 Total files downloaded: {result['total_files']}")
        print(f"💾 Total size: {result['total_size_mb']} MB")
        
        if result['failed_downloads'] > 0:
            print(f"⚠️  Failed downloads: {result['failed_downloads']}")
            print(f"   Check the log file for details")
        
        print(f"\n📊 Reports generated:")
        print(f"   - Scraping log: {output_dir}/scraping_log.txt")
        print(f"   - Comprehensive report: {output_dir}/comprehensive_scraping_report.json")
        print(f"   - Dependency graph: {output_dir}/dependency_graph.json")
        print(f"   - Generated sitemap: {output_dir}/generated_sitemap.xml")
        
        return result
        
    except KeyboardInterrupt:
        print("\n❌ Scraping interrupted by user")
        return None
    except Exception as e:
        print(f"\n❌ Scraping failed: {e}")
        return None

def interactive_setup():
    """Interactive setup for the scraper"""
    print("🕷️  Comprehensive Web Scraper - Interactive Setup")
    print("="*50)
    
    # Get URL
    url = input("Enter the website URL to scrape: ").strip()
    if not url.startswith(('http://', 'https://')):
        url = 'https://' + url
    
    # Show presets
    config_manager = ScraperConfig()
    print("\nAvailable presets:")
    config_manager.list_presets()
    
    # Get preset
    preset = input("Choose a preset (default: standard): ").strip() or 'standard'
    
    # Get output directory
    from urllib.parse import urlparse
    default_output = urlparse(url).netloc.replace('www.', '') + '_mirror'
    output_dir = input(f"Output directory (default: {default_output}): ").strip() or default_output
    
    # Authentication
    auth_username = None
    auth_password = None
    if input("Does the site require authentication? (y/N): ").strip().lower() == 'y':
        auth_username = input("Username: ").strip()
        auth_password = input("Password: ").strip()
    
    # Custom settings
    custom_depth = None
    custom_rate_limit = None
    
    if input("Customize advanced settings? (y/N): ").strip().lower() == 'y':
        try:
            depth_input = input("Max crawling depth (leave empty for preset default): ").strip()
            if depth_input:
                custom_depth = int(depth_input)
                
            rate_input = input("Rate limit in seconds (leave empty for preset default): ").strip()
            if rate_input:
                custom_rate_limit = float(rate_input)
        except ValueError:
            print("Invalid input, using preset defaults")
    
    return {
        'url': url,
        'preset': preset,
        'output_dir': output_dir,
        'auth_username': auth_username,
        'auth_password': auth_password,
        'custom_depth': custom_depth,
        'custom_rate_limit': custom_rate_limit
    }

async def main():
    """Main entry point"""
    import sys
    
    if len(sys.argv) > 1:
        # Command line mode
        url = sys.argv[1]
        preset = sys.argv[2] if len(sys.argv) > 2 else 'standard'
        
        await run_scraper_with_config(url, preset)
    else:
        # Interactive mode
        config = interactive_setup()
        
        print(f"\n🚀 Starting scraper...")
        await run_scraper_with_config(**config)

if __name__ == "__main__":
    asyncio.run(main())