import Cocoa
import Foundation

class PinnedImageWindow: NSWindow {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.level = NSWindow.Level.floating
        self.styleMask = [.borderless]
        self.isOpaque = false
        self.hasShadow = true
        self.ignoresMouseEvents = false
    }
    
    init(contentRect: NSRect) {
        super.init(contentRect: contentRect, styleMask: [.borderless], backing: .buffered, defer: false)
        self.level = NSWindow.Level.floating
        self.isOpaque = false
        self.hasShadow = true
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.backgroundColor = NSColor.clear
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        if event.characters == "q" || event.characters == "Q" {
            self.close()
        } else {
            super.keyDown(with: event)
        }
    }
}

class OverlayView: NSView {
    var closeButton: NSView!
    var resizeHandle: NSView!
    weak var parentImageView: PinnedImageView?
    private var trackingArea: NSTrackingArea?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupControls()
        setupTrackingArea()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupControls()
        setupTrackingArea()
    }
    
    func setupControls() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        
        let closeButtonSize: CGFloat = 24
        closeButton = NSView(frame: NSRect(x: bounds.width - closeButtonSize - 8, y: bounds.height - closeButtonSize - 8, width: closeButtonSize, height: closeButtonSize))
        closeButton.wantsLayer = true
        closeButton.layer?.backgroundColor = NSColor.clear.cgColor
        closeButton.layer?.cornerRadius = closeButtonSize / 2
        
        let xLayer = CAShapeLayer()
        let xPath = CGMutablePath()
        let inset: CGFloat = 7
        xPath.move(to: CGPoint(x: inset, y: inset))
        xPath.addLine(to: CGPoint(x: closeButtonSize - inset, y: closeButtonSize - inset))
        xPath.move(to: CGPoint(x: closeButtonSize - inset, y: inset))
        xPath.addLine(to: CGPoint(x: inset, y: closeButtonSize - inset))
        xLayer.path = xPath
        xLayer.strokeColor = NSColor.white.withAlphaComponent(0.9).cgColor
        xLayer.lineWidth = 2.0
        xLayer.lineCap = .round
        closeButton.layer?.addSublayer(xLayer)
        closeButton.isHidden = true
        addSubview(closeButton)
        
        let resizeHandleSize: CGFloat = 20
        resizeHandle = NSView(frame: NSRect(x: bounds.width - resizeHandleSize - 8, y: 8, width: resizeHandleSize, height: resizeHandleSize))
        resizeHandle.wantsLayer = true
        resizeHandle.layer?.backgroundColor = NSColor.clear.cgColor
        resizeHandle.layer?.cornerRadius = 6
        
        let gripLayer = CAShapeLayer()
        let gripPath = CGMutablePath()
        let dotSize: CGFloat = 1.5
        let spacing: CGFloat = 3.5
        let startX: CGFloat = resizeHandleSize - 14
        let startY: CGFloat = 6
        
        for row in 0..<3 {
            for col in 0..<3 {
                if row + col >= 1 {
                    let x = startX + CGFloat(col) * spacing
                    let y = startY + CGFloat(row) * spacing
                    gripPath.addEllipse(in: CGRect(x: x, y: y, width: dotSize, height: dotSize))
                }
            }
        }
        
        gripLayer.path = gripPath
        gripLayer.fillColor = NSColor.white.withAlphaComponent(0.9).cgColor
        resizeHandle.layer?.addSublayer(gripLayer)
        resizeHandle.isHidden = true
        addSubview(resizeHandle)
    }
    
    func setupTrackingArea() {
        if let existingTrackingArea = trackingArea {
            removeTrackingArea(existingTrackingArea)
        }
        
        trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeInKeyWindow, .mouseEnteredAndExited, .mouseMoved],
            owner: self,
            userInfo: nil
        )
        
        if let trackingArea = trackingArea {
            addTrackingArea(trackingArea)
        }
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        setupTrackingArea()
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        showButtons()
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        hideButtons()
    }
    
    private func showButtons() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            closeButton.animator().isHidden = false
            resizeHandle.animator().isHidden = false
        }
    }
    
    private func hideButtons() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            closeButton.animator().isHidden = true
            resizeHandle.animator().isHidden = true
        }
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        if closeButton != nil && resizeHandle != nil {
            let closeButtonSize: CGFloat = 24
            closeButton.frame = NSRect(x: newSize.width - closeButtonSize - 8, y: newSize.height - closeButtonSize - 8, width: closeButtonSize, height: closeButtonSize)
            
            let resizeHandleSize: CGFloat = 20
            resizeHandle.frame = NSRect(x: newSize.width - resizeHandleSize - 8, y: 8, width: resizeHandleSize, height: resizeHandleSize)
        }
        setupTrackingArea()
    }
    
    override func mouseDown(with event: NSEvent) {
        let locationInView = convert(event.locationInWindow, from: nil)
        
        if closeButton.frame.contains(locationInView) {
            window?.close()
            return
        }
        
        if resizeHandle.frame.contains(locationInView) {
            parentImageView?.startResizing(with: event)
            return
        }
        
        window?.performDrag(with: event)
    }
    
    override func scrollWheel(with event: NSEvent) {
        guard let window = window else { return }
        
        let scrollDelta = event.scrollingDeltaY
        let currentAlpha = window.alphaValue
        let alphaChange: CGFloat = scrollDelta > 0 ? 0.05 : -0.05
        let newAlpha = max(0.1, min(1.0, currentAlpha + alphaChange))
        
        window.alphaValue = newAlpha
    }
}

class PinnedImageView: NSImageView {
    var overlayView: OverlayView!
    var originalAspectRatio: CGFloat = 1.0
    
    func setupControls() {
        overlayView = OverlayView(frame: bounds)
        overlayView.parentImageView = self
        addSubview(overlayView)
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        if overlayView != nil {
            overlayView.frame = NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        }
    }
    
    func startResizing(with event: NSEvent) {
        guard let window = window else { return }
        
        var keepGoing = true
        var lastLocation = event.locationInWindow
        
        while keepGoing {
            guard let nextEvent = window.nextEvent(matching: [.leftMouseDragged, .leftMouseUp]) else { continue }
            
            switch nextEvent.type {
            case .leftMouseDragged:
                let currentLocation = nextEvent.locationInWindow
                let deltaX = currentLocation.x - lastLocation.x
                
                var frame = window.frame
                let newWidth = max(100, frame.size.width + deltaX)
                let newHeight = newWidth / originalAspectRatio
                
                frame.size.width = newWidth
                frame.size.height = newHeight
                frame.origin.y = frame.origin.y + frame.size.height - newHeight
                
                window.setFrame(frame, display: true)
                lastLocation = currentLocation
                
            case .leftMouseUp:
                keepGoing = false
                
            default:
                break
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: PinnedImageWindow?
    var imageView: PinnedImageView?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let args = CommandLine.arguments
        
        guard args.count > 1 else {
            print("Usage: pin <image_path>")
            NSApp.terminate(nil)
            return
        }
        
        let imagePath = args[1]
        let expandedPath = NSString(string: imagePath).expandingTildeInPath
        
        guard let image = NSImage(contentsOfFile: expandedPath) else {
            print("Error: Could not load image from '\(imagePath)'")
            NSApp.terminate(nil)
            return
        }
        
        let imageSize = image.size
        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        
        let maxWidth = screenFrame.width * 0.8
        let maxHeight = screenFrame.height * 0.8
        
        var windowSize = imageSize
        if windowSize.width > maxWidth || windowSize.height > maxHeight {
            let widthRatio = maxWidth / windowSize.width
            let heightRatio = maxHeight / windowSize.height
            let ratio = min(widthRatio, heightRatio)
            windowSize.width *= ratio
            windowSize.height *= ratio
        }
        
        let windowRect = NSRect(
            x: (screenFrame.width - windowSize.width) / 2,
            y: (screenFrame.height - windowSize.height) / 2,
            width: windowSize.width,
            height: windowSize.height
        )
        
        window = PinnedImageWindow(contentRect: windowRect)
        
        imageView = PinnedImageView(frame: NSRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height))
        imageView?.image = image
        imageView?.imageScaling = .scaleProportionallyUpOrDown
        imageView?.originalAspectRatio = imageSize.width / imageSize.height
        imageView?.wantsLayer = true
        imageView?.layer?.backgroundColor = NSColor.clear.cgColor
        imageView?.layer?.cornerRadius = 12
        imageView?.layer?.masksToBounds = true
        imageView?.setupControls()
        
        window?.contentView = imageView
        window?.alphaValue = 0.9
        window?.makeKeyAndOrderFront(nil)
        window?.makeKey()
        window?.center()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

NSApp.setActivationPolicy(.accessory)

DispatchQueue.main.async {
    NSApp.setActivationPolicy(.regular)
}

app.run()
