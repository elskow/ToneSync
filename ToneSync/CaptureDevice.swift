//
// Created by Helmy LuqmanulHakim on 21/12/24.
//

import AVFoundation
import Foundation

struct CaptureDevice {
    let name: String
    let avDevice: AVCaptureDevice

    init(device: AVCaptureDevice) {
        self.name = device.localizedName
        self.avDevice = device
    }
}