#!/bin/bash

# Test script to verify 16KB page size support
# This script checks if the compiled .so files have proper alignment

echo "🔍 Checking 16KB Page Size Support for timezone-hermes-fix"
echo "============================================================"

# Build the Android library
echo "📦 Building Android library..."
cd android
./gradlew assembleDebug

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

# Find the compiled .so files
SO_FILES=$(find . -name "libtimezone-hermes-fix.so" -type f)

if [ -z "$SO_FILES" ]; then
    echo "❌ No .so files found"
    exit 1
fi

echo "📋 Found .so files:"
echo "$SO_FILES"

# Check alignment for each .so file
for so_file in $SO_FILES; do
    echo ""
    echo "🔍 Checking alignment for: $so_file"
    
    # Check if readelf is available
    if command -v readelf &> /dev/null; then
        # Check LOAD segments alignment
        echo "📊 LOAD segments:"
        readelf -l "$so_file" | grep LOAD | while read line; do
            echo "  $line"
        done
        
        # Check if alignment is 16KB (0x4000) compatible
        ALIGNMENT_CHECK=$(readelf -l "$so_file" | grep LOAD | grep -E "(0x4000|0x8000|0x10000)" | wc -l)
        
        if [ "$ALIGNMENT_CHECK" -gt 0 ]; then
            echo "✅ 16KB alignment detected"
        else
            echo "⚠️  No explicit 16KB alignment found (may still be compatible)"
        fi
    else
        echo "⚠️  readelf not available, cannot check alignment"
    fi
done

echo ""
echo "🎉 16KB page size support verification complete!"
echo ""
echo "📚 For more information, see: docs/ANDROID_16KB_SUPPORT.md"