//
// Created by Helmy LuqmanulHakim on 21/12/24.
//

import Foundation
import IOKit
import IOKit.usb

class USBHelper {
    static func findUSBDevice(withVendorID vendorID: Int, productID: Int) -> io_service_t? {
        let matchingDict = IOServiceMatching(kIOUSBDeviceClassName) as NSMutableDictionary
        matchingDict[kUSBVendorID] = NSNumber(value: vendorID)
        matchingDict[kUSBProductID] = NSNumber(value: productID)

        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iterator)

        guard result == KERN_SUCCESS else {
            return nil
        }

        let device = IOIteratorNext(iterator)
        IOObjectRelease(iterator)

        return device != 0 ? device : nil
    }

    static func getUSBDeviceInfo(device: io_service_t) -> (vendorID: Int, productID: Int)? {
        var vendorID: Int = 0
        var productID: Int = 0

        var propertyIterator: io_iterator_t = 0
        let result = IORegistryEntryCreateIterator(
            device,
            kIOServicePlane,
            IOOptionBits(kIORegistryIterateRecursively),
            &propertyIterator
        )

        guard result == KERN_SUCCESS else {
            return nil
        }

        var current = IOIteratorNext(propertyIterator)
        while current != 0 {
            var propertyDict: Unmanaged<CFMutableDictionary>?
            if IORegistryEntryCreateCFProperties(current, &propertyDict, kCFAllocatorDefault, 0) == KERN_SUCCESS,
               let dict = propertyDict?.takeRetainedValue() as NSDictionary? {
                if let idVendor = dict["idVendor"] as? Int {
                    vendorID = idVendor
                }
                if let idProduct = dict["idProduct"] as? Int {
                    productID = idProduct
                }
            }
            IOObjectRelease(current)
            current = IOIteratorNext(propertyIterator)
        }

        IOObjectRelease(propertyIterator)

        return (vendorID, productID)
    }
}