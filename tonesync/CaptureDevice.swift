//
// Created by Helmy LuqmanulHakim on 21/12/24.
//

import AVFoundation
import Foundation

struct CaptureDevice: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let avDevice: AVCaptureDevice

    init(device: AVCaptureDevice) {
        self.name = device.localizedName
        self.avDevice = device
    }

    static func ==(lhs: CaptureDevice, rhs: CaptureDevice) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}