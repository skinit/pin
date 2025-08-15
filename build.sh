#!/bin/bash

echo "Building pin image viewer..."
swiftc -o pin main.swift -framework Cocoa -framework Foundation

if [ $? -eq 0 ]; then
    echo "Build successful! Binary created: ./pin"
    echo ""
    echo "Usage (independent/non-blocking): ./pin.sh <path_to_image>"
    echo "Usage (direct): ./pin <path_to_image>"
    echo "Example: ./pin.sh ~/Desktop/image.jpg"
    echo ""
    echo "Use pin.sh to run independently without blocking your terminal."
    echo "Use pin directly if you want it to run in the foreground."
else
    echo "Build failed!"
    exit 1
fi