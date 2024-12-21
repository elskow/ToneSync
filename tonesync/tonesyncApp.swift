//
//  tonesyncApp.swift
//  tonesync
//
//  Created by Helmy LuqmanulHakim on 21/12/24.
//
//

import SwiftUI

@main
struct tonesyncApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { }  // Empty settings scene since we're using popover
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarManager: StatusBarManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarManager = StatusBarManager()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let device = CameraManager.shared.currentDevice {
            CameraManager.shared.resetCamera(device)
        }
        CameraManager.shared.setPreviewActive(false)
        USBHelper.clearCache()
    }
}
