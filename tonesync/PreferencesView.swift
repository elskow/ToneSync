//
// Created by Helmy LuqmanulHakim on 22/12/24.
//

import Foundation
import SwiftUI

struct PreferencesView: View {
    @State private var launchAtLogin: Bool = LaunchAtLogin.shared.isEnabled
    @AppStorage("AutoOptimizeOnLaunch") private var autoOptimizeOnLaunch = true

    var body: some View {
        Form {
            Toggle("Launch at Login", isOn: Binding(
                get: { launchAtLogin },
                set: { newValue in
                    launchAtLogin = newValue
                    LaunchAtLogin.shared.isEnabled = newValue
                }
            ))
            Toggle("Auto-optimize on Launch", isOn: $autoOptimizeOnLaunch)
        }
        .padding()
        .frame(width: 300)
    }
}