//
// Created by Helmy LuqmanulHakim on 22/12/24.
//

import Foundation
import ServiceManagement

class LaunchAtLogin {
    static let shared = LaunchAtLogin()

    private let launchAgentIdentifier: String

    private init() {
        launchAgentIdentifier = Bundle.main.bundleIdentifier ?? ""
    }

    var isEnabled: Bool {
        get {
            return SMAppService.mainApp.status == .enabled
        }
        set {
            do {
                if newValue {
                    if SMAppService.mainApp.status == .enabled {
                        try SMAppService.mainApp.unregister()
                    }
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(newValue ? "enable" : "disable") launch at login: \(error)")
            }
        }
    }
}
