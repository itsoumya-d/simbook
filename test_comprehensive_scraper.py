#!/usr/bin/env python3
"""
Test script for the Comprehensive Web Scraper
Demonstrates usage with a simple example
"""

import asyncio
import sys
from pathlib import Path
from comprehensive_web_scraper import ComprehensiveWebScraper

async def test_comprehensive_scraper():
    """Test the comprehensive scraper with a simple website"""
    print("🧪 Testing Comprehensive Web Scraper...")
    print("="*50)
    
    # Test with a simple, public website
    test_url = "https://httpbin.org"  # Simple API testing site
    output_dir = "httpbin_test_mirror"
    
    print(f"🎯 Target: {test_url}")
    print(f"📁 Output: {output_dir}")
    print(f"🔍 Depth: 2 (limited for testing)")
    print(f"⏱️  Rate limit: 1.0s")
    print()
    
    try:
        # Create scraper with conservative settings for testing
        scraper = ComprehensiveWebScraper(
            base_url=test_url,
            max_depth=2,  # Limited depth for testing
            rate_limit=1.0,  # Respectful rate limiting
            output_dir=output_dir
        )
        
        print("🚀 Starting test scrape...")
        result = await scraper.run()
        
        print("\n" + "="*50)
        print("✅ TEST COMPLETED SUCCESSFULLY!")
        print("="*50)
        print(f"📄 Files downloaded: {result['total_files']}")
        print(f"💾 Total size: {result['total_size_mb']} MB")
        
        if result['failed_downloads'] > 0:
            print(f"⚠️  Failed downloads: {result['failed_downloads']}")
        
        # Show directory structure
        output_path = Path(output_dir)
        if output_path.exists():
            print(f"\n📁 Directory structure:")
            for item in sorted(output_path.rglob("*")):
                if item.is_file():
                    relative_path = item.relative_to(output_path)
                    size_kb = item.stat().st_size / 1024
                    print(f"   {relative_path} ({size_kb:.1f} KB)")
        
        print(f"\n📊 Generated reports:")
        print(f"   - {output_dir}/scraping_log.txt")
        print(f"   - {output_dir}/comprehensive_scraping_report.json")
        print(f"   - {output_dir}/dependency_graph.json")
        
        return True
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        return False

async def demo_features():
    """Demonstrate key features of the comprehensive scraper"""
    print("\n🌟 Comprehensive Web Scraper Features:")
    print("="*50)
    
    features = [
        "✅ HTML pages with JavaScript rendering",
        "✅ CSS stylesheets (external and inline)",
        "✅ JavaScript files and modules",
        "✅ Images (JPG, PNG, GIF, SVG, WebP, ICO)",
        "✅ Videos and audio files",
        "✅ Font files (WOFF, WOFF2, TTF, OTF)",
        "✅ JSON data and API responses",
        "✅ XML files and sitemaps",
        "✅ Favicons and app icons",
        "✅ Metadata and manifest files",
        "✅ Authentication support",
        "✅ Rate limiting and robots.txt compliance",
        "✅ Dependency tracking and mapping",
        "✅ Comprehensive error handling",
        "✅ Progress monitoring and statistics",
        "✅ Complete offline website mirrors"
    ]
    
    for feature in features:
        print(f"  {feature}")
    
    print(f"\n🎛️  Configuration Presets:")
    presets = {
        'basic': 'Quick overview, minimal depth',
        'standard': 'Balanced approach for most sites',
        'comprehensive': 'Deep scraping for complete mirrors',
        'aggressive': 'Maximum coverage and speed',
        'respectful': 'Slow and careful scraping'
    }
    
    for preset, description in presets.items():
        print(f"  {preset}: {description}")
    
    print(f"\n📋 Usage Examples:")
    examples = [
        "python comprehensive_web_scraper.py https://example.com",
        "python comprehensive_web_scraper.py https://example.com --depth 5",
        "python comprehensive_web_scraper.py https://example.com --username user --password pass",
        "python scraper_config.py  # Interactive mode",
        "python scraper_config.py https://example.com comprehensive"
    ]
    
    for example in examples:
        print(f"  {example}")

async def main():
    """Main test function"""
    await demo_features()
    
    print(f"\n" + "="*60)
    print("🧪 RUNNING TEST SCRAPE")
    print("="*60)
    
    # Ask user if they want to run the test
    if len(sys.argv) > 1 and sys.argv[1] == '--run-test':
        success = await test_comprehensive_scraper()
        if success:
            print(f"\n🎉 All tests passed! The comprehensive scraper is ready to use.")
        else:
            print(f"\n🔧 Please check the setup and try again.")
    else:
        print("To run the actual test, use: python test_comprehensive_scraper.py --run-test")
        print("This will create a test download from httpbin.org")

if __name__ == "__main__":
    asyncio.run(main())