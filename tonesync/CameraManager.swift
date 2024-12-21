//
// Created by Helmy LuqmanulHakim on 21/12/24.
//

import AVFoundation
import Foundation
import IOKit
import IOKit.usb


class CameraManager: ObservableObject {
    static let shared = CameraManager()

    @Published var currentDevice: CaptureDevice?
    @Published var availableDevices: [CaptureDevice] = []
    @Published private(set) var isOptimized: Bool = false

    init() {
        loadDevices()
    }

    func loadDevices() {
        let session = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.externalUnknown, .builtInWideAngleCamera],
                mediaType: .video,
                position: .unspecified
        )

        availableDevices = session.devices.map { device in
            CaptureDevice(device: device)
        }

        if let first = availableDevices.first {
            currentDevice = first
            optimizeCamera(first)
        }
    }

    func optimizeCamera(_ device: CaptureDevice) {
        do {
            isOptimized = false
            try device.avDevice.lockForConfiguration()

            if device.avDevice.isWhiteBalanceModeSupported(.locked) {
                device.avDevice.whiteBalanceMode = .locked
            }

            if device.avDevice.isExposureModeSupported(.locked) {
                device.avDevice.exposureMode = .locked
            }

            if let location = device.avDevice.value(forKey: "connectionID") as? Int {
                var iterator: io_iterator_t = 0
                let matching = IOServiceMatching(kIOUSBDeviceClassName)
                let result = IOServiceGetMatchingServices(kIOMasterPortDefault, matching, &iterator)

                if result == KERN_SUCCESS {
                    var usbDevice = IOIteratorNext(iterator)
                    while usbDevice != 0 {
                        if let (vendorID, productID) = USBHelper.getUSBDeviceInfo(device: usbDevice) {
                            switch vendorID {
                            case 0x046d: // Logitech
                                optimizeLogitech(usbDevice)
                            case 0x0c45: // Microdia/Generic
                                optimizeGeneric(usbDevice)
                            default:
                                optimizeGeneric(usbDevice)
                            }
                        }
                        IOObjectRelease(usbDevice)
                        usbDevice = IOIteratorNext(iterator)
                    }
                    IOObjectRelease(iterator)
                }
            }

            if device.avDevice.isExposureModeSupported(.continuousAutoExposure) {
                device.avDevice.exposureMode = .continuousAutoExposure
            }

            if device.avDevice.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                device.avDevice.whiteBalanceMode = .continuousAutoWhiteBalance
            }

            device.avDevice.unlockForConfiguration()
            isOptimized = true
        } catch {
            print("Could not configure camera: \(error)")
            isOptimized = false
        }
    }

    private func optimizeLogitech(_ device: io_service_t) {
        // Logitech specific optimizations
        // Set common Logitech webcam controls for better skin tones
        let controls: [(UInt8, UInt8)] = [
            (0x81, 0x03), // Auto exposure off
            (0x82, 0x80), // Manual exposure value
            (0x80, 0x04), // Manual white balance
            (0x83, 0x60), // White balance temperature
            (0x84, 0x70), // Contrast
            (0x85, 0x60), // Brightness
            (0x86, 0x60), // Saturation
            (0x87, 0x50)  // Sharpness
        ]

        for (control, value) in controls {
            if USBHelper.isControlSupported(device: device, control: control) {
                sendUSBControl(device: device, request: control, value: value)
            }
        }
    }

    private func optimizeGeneric(_ device: io_service_t) {
        // Generic USB webcam optimizations
        // Use standard UVC controls
        let controls: [(UInt8, UInt8)] = [
            (0x02, 0x01), // Manual mode
            (0x03, 0x80), // Exposure
            (0x04, 0x80), // Brightness
            (0x05, 0x80), // Contrast
            (0x06, 0x80), // Gain
            (0x07, 0x80), // Saturation
            (0x08, 0x40)  // White balance
        ]

        for (control, value) in controls {
            if USBHelper.isControlSupported(device: device, control: control) {
                sendUSBControl(device: device, request: control, value: value)
            }
        }
    }

    private func sendUSBControl(device: io_service_t, request: UInt8, value: UInt8) {
        var dataSize: Int = 1
        var data: UInt8 = value

        let kr = IORegistryEntrySetCFProperty(
                device,
                ("UVC_CTRL_" + String(format: "%02X", request)) as CFString,
                NSData(bytes: &data, length: dataSize) as CFData
        )

        if kr != KERN_SUCCESS {
            #if DEBUG
            print("Failed to set USB control: \(String(format: "0x%02X", request))")
            #endif
        }
    }

    func resetCamera(_ device: CaptureDevice) {
        do {
            isOptimized = false
            try device.avDevice.lockForConfiguration()

            if device.avDevice.isExposureModeSupported(.continuousAutoExposure) {
                device.avDevice.exposureMode = .continuousAutoExposure
            }

            if device.avDevice.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                device.avDevice.whiteBalanceMode = .continuousAutoWhiteBalance
            }

            device.avDevice.unlockForConfiguration()
        } catch {
            print("Could not reset camera: \(error)")
        }
    }
}

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