//
// Created by Helmy LuqmanulHakim on 21/12/24.
//

import SwiftUI
import AppKit

class StatusBarManager {
    private var statusItem: NSStatusItem!
    private lazy var popover: NSPopover = {
        let pop = NSPopover()
        pop.contentSize = NSSize(width: 360, height: 380)
        pop.behavior = .transient

        let contentView = ContentView()
            .background(Color.clear)

        let hostingController = NSHostingController(rootView: contentView)
        hostingController.view.appearance = NSAppearance(named: .vibrantDark)

        pop.contentViewController = hostingController
        pop.appearance = NSAppearance(named: .vibrantDark)

        if let effectView = pop.contentViewController?.view.superview?.subviews.first(where: { $0 is NSVisualEffectView }) as? NSVisualEffectView {
            effectView.material = .hudWindow
            effectView.state = .active
            effectView.blendingMode = .behindWindow
        }

        return pop
    }()

    init() {
        setupStatusItem()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            if let image = NSImage(systemSymbolName: "video.fill", accessibilityDescription: "Camera") {
                image.isTemplate = true
                button.image = image
            }
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            closePopover()
        } else {
            showPopover(button)
        }
    }

    private func showPopover(_ button: NSStatusBarButton) {
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        CameraManager.shared.setPreviewActive(true)

        if let window = popover.contentViewController?.view.window {
            window.isOpaque = false
            window.backgroundColor = .clear
            window.makeKey()
        }

        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            self?.closePopover()
        }
    }

    private func closePopover() {
        popover.performClose(nil)
        CameraManager.shared.setPreviewActive(false)
    }

    deinit {
        NSEvent.removeMonitor(self)
    }
}