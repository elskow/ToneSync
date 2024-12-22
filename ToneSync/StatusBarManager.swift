//
// Created by Helmy LuqmanulHakim on 21/12/24.
//

import SwiftUI
import AppKit
import AVFoundation
import UserNotifications

class StatusBarManager: NSObject {
    private var statusItem: NSStatusItem!
    private var preferencesWindow: NSWindow?

    override init() {
        super.init()
        setupStatusItem()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            if let iconImage = NSImage(named: "AppIcon") {
                iconImage.size = NSSize(width: 18, height: 18)
                iconImage.isTemplate = true
                button.image = iconImage
            }

            let menu = NSMenu()

            let optimizeItem = NSMenuItem(title: "Optimize Camera", action: #selector(optimizeCamera), keyEquivalent: "o")
            optimizeItem.target = self
            menu.addItem(optimizeItem)

            let resetItem = NSMenuItem(title: "Reset Camera", action: #selector(resetCamera), keyEquivalent: "r")
            resetItem.target = self
            menu.addItem(resetItem)

            menu.addItem(NSMenuItem.separator())

            let preferencesItem = NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ",")
            preferencesItem.target = self
            menu.addItem(preferencesItem)

            menu.addItem(NSMenuItem.separator())

            let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
            quitItem.target = self
            menu.addItem(quitItem)

            statusItem.menu = menu
        }
    }

    @objc private func showPreferences() {
        if let window = preferencesWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 150),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = "Preferences"
        window.contentView = NSHostingView(rootView: PreferencesView())
        window.center()
        window.isReleasedWhenClosed = false
        window.hidesOnDeactivate = false
        window.delegate = self
        preferencesWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func optimizeCamera() {
        if let device = CameraManager.shared.currentDevice {
            CameraManager.shared.optimizeCamera(device)

            showNotification(title: "Camera Optimized",
                    message: "Camera settings have been optimized for better skin tones")
        }
    }

    @objc private func resetCamera() {
        if let device = CameraManager.shared.currentDevice {
            CameraManager.shared.resetCamera(device)

            showNotification(title: "Camera Reset",
                    message: "Camera settings have been reset to default")
        }
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }


    private func showNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error showing notification: \(error)")
            }
        }
    }
}


extension StatusBarManager: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            window.orderOut(nil)
        }
    }
}
