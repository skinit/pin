# Pin - Floating Image Viewer for macOS

A lightweight macOS command-line application that displays images in always-on-top floating windows, perfect for keeping reference images visible while working.

## Features

- **Always on top**: Images stay pinned above all other windows, even when focus changes
- **Borderless design**: Clean, minimal interface without window decorations
- **Modern UI controls**: Transparent buttons with contemporary styling
- **Proportional resizing**: Maintains image aspect ratio during resize operations
- **Multiple images**: Open several images simultaneously using wildcards
- **Transparency control**: Adjust window opacity with mouse wheel scrolling
- **Keyboard shortcuts**: Press 'q' to close windows quickly
- **Independent process**: Runs detached from the terminal for uninterrupted workflow

## Installation

1. Clone this repository
2. Build the application:

   ```bash
   swift build -c release
   ```

3. Make the shell script executable:

   ```bash
   chmod +x pin.sh
   ```

## Usage

### Single Image

```bash
./pin.sh /path/to/image.jpg
```

### Multiple Images (using wildcards)

```bash
./pin.sh *.jpg
./pin.sh Images/*.png
./pin.sh ~/Pictures/screenshots/Screen*.png
```

### Supported Formats

Any image format supported by macOS (JPEG, PNG, GIF, TIFF, BMP, etc.)

## Controls

### Mouse Controls

- **Drag anywhere**: Move the window
- **X button (top-right)**: Close window
- **Grip handle (bottom-right)**: Resize window (maintains aspect ratio)
- **Mouse wheel**: Adjust window transparency (scroll up = more opaque, scroll down = more transparent)

### Keyboard Shortcuts

- **q**: Close the current window

## Technical Details

- Built with Swift and Cocoa
- Uses `NSWindow.Level.floating` for always-on-top behavior
- Borderless window design (`styleMask: [.borderless]`)
- Independent process execution via `nohup`
- Proportional resizing maintains original image aspect ratios
- Transparency range: 10% to 100% opacity

## Use Cases

- **Design Reference**: Keep UI mockups, color palettes, or design specs visible while coding
- **Photo Editing**: Compare before/after images side by side
- **Documentation**: Pin screenshots or diagrams while writing
- **Art/Drawing**: Reference images for digital art or sketching
- **Development**: Keep API documentation, wireframes, or flowcharts accessible

## Requirements

- macOS 10.12+ (Sierra or later)
- Xcode command line tools or Swift toolchain

## License

MIT License - Feel free to use, modify, and distribute.

## Contributing

Pull requests and issues welcome! Please ensure all changes maintain the minimalist design philosophy and cross-platform compatibility within the macOS ecosystem.

