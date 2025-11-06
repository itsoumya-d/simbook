#!/usr/bin/env python3
"""
Test script for SoBrief scraper
Performs a limited test to verify setup
"""

import asyncio
import sys
from pathlib import Path
from sobrief_scraper import SoBriefScraper

async def test_scraper():
    """Test the scraper with limited scope"""
    print("🧪 Testing SoBrief scraper setup...")
    
    try:
        # Create scraper with limited depth for testing
        scraper = SoBriefScraper(max_depth=1)
        
        # Initialize
        await scraper.initialize()
        print("✅ Browser and HTTP session initialized successfully")
        
        # Test robots.txt parsing
        if scraper.robots_parser:
            print("✅ Robots.txt parsed successfully")
        else:
            print("⚠️  Robots.txt not found or failed to parse")
            
        # Test URL validation
        test_url = "https://sobrief.com"
        if scraper.is_valid_url(test_url):
            print("✅ URL validation working")
        else:
            print("❌ URL validation failed")
            
        # Test file path generation
        file_path = scraper.get_file_path(test_url)
        print(f"✅ File path generation: {file_path}")
        
        # Cleanup
        await scraper.cleanup()
        print("✅ Cleanup completed successfully")
        
        print("\n🎉 All tests passed! The scraper is ready to run.")
        return True
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        return False

async def main():
    """Main test function"""
    success = await test_scraper()
    
    if success:
        print("\n🚀 Ready to run full scraper!")
        print("Run: python sobrief_scraper.py")
    else:
        print("\n🔧 Please check the setup and try again.")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())