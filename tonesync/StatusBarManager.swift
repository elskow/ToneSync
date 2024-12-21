//
// Created by Helmy LuqmanulHakim on 21/12/24.
//

import SwiftUI
import AppKit

class StatusBarManager {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

    init() {
        createStatusBarItem()
        createPopover()
    }

    private func createStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "video.fill", accessibilityDescription: "Camera")
            statusButton.action = #selector(togglePopover)
            statusButton.target = self
        }
    }

    private func createPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 380)
        popover.behavior = .transient

        let contentView = ContentView()
            .background(Color.clear)

        let hostingController = NSHostingController(rootView: contentView)
        hostingController.view.appearance = NSAppearance(named: .vibrantDark)

        popover.contentViewController = hostingController

        popover.appearance = NSAppearance(named: .vibrantDark)
        if let effectView = popover.contentViewController?.view.superview?.subviews.first(where: { $0 is NSVisualEffectView }) as? NSVisualEffectView {
            effectView.material = .hudWindow
            effectView.state = .active
            effectView.blendingMode = .behindWindow
        }
    }

    @objc private func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)

                if let window = popover.contentViewController?.view.window {
                    window.isOpaque = false
                    window.backgroundColor = .clear

                    window.makeKey()
                }
            }
        }
    }
}