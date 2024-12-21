//
//  ContentView.swift
//  tonesync
//
//  Created by Helmy LuqmanulHakim on 21/12/24.
//
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager.shared
    @Environment(\.colorScheme) var colorScheme

    private struct Layout {
        static let spacing: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let statusBadgeHeight: CGFloat = 28
    }

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: Layout.spacing) {
                if !cameraManager.availableDevices.isEmpty {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .foregroundColor(AppColors.text)
                            .font(.system(size: 14))

                        Picker("", selection: $cameraManager.currentDevice) {
                            ForEach(cameraManager.availableDevices) { device in
                                Text(device.name).tag(Optional(device))
                            }
                        }
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        .onChange(of: cameraManager.currentDevice) { newDevice in
                            if let device = newDevice {
                                cameraManager.optimizeCamera(device)
                            }
                        }
                    }
                    .padding(10)
                    .background(AppColors.surface)
                    .cornerRadius(8)

                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(cameraManager.isOptimized ? AppColors.success : AppColors.warning)
                                .frame(width: 6, height: 6)
                            Text(cameraManager.isOptimized ? "Optimized" : "Standard")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(AppColors.text)
                        }
                        .frame(height: Layout.statusBadgeHeight)
                        .padding(.horizontal, 12)
                        .background(AppColors.surface)
                        .cornerRadius(Layout.statusBadgeHeight/2)

                        CameraPreview(device: cameraManager.currentDevice?.avDevice)
                            .frame(width: 320, height: 240)
                            .cornerRadius(Layout.cornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: Layout.cornerRadius)
                                    .stroke(AppColors.surface, lineWidth: 1)
                            )
                    }

                    HStack(spacing: 12) {
                        Button(action: {
                            if let device = cameraManager.currentDevice {
                                cameraManager.resetCamera(device)
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Reset")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(GlassButtonStyle())

                        Button(action: {
                            NSApplication.shared.terminate(nil)
                        }) {
                            HStack {
                                Image(systemName: "xmark")
                                Text("Quit")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(GlassButtonStyle(isDestructive: true))
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "camera.slash.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.warning)

                        Text("No Camera Connected")
                            .font(.headline)
                            .foregroundColor(AppColors.text)

                        Text("Please connect a camera to continue")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.surface)
                    .cornerRadius(Layout.cornerRadius)
                }
            }
            .padding(Layout.spacing)
        }
        .frame(width: 360, height: 400)
        .background(Color.clear)
    }
}

struct GlassButtonStyle: ButtonStyle {
    var isDestructive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isDestructive ? Color.red.opacity(0.3) : AppColors.surface)
                .foregroundColor(AppColors.text)
                .cornerRadius(8)
                .overlay(
                        RoundedRectangle(cornerRadius: 8)
                                .stroke(isDestructive ? Color.red.opacity(0.5) : AppColors.surface, lineWidth: 1)
                )
                .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

struct CameraPreview: NSViewRepresentable {
    let device: AVCaptureDevice?
    private var session: AVCaptureSession?

    init(device: AVCaptureDevice?) {
        self.device = device
        if let device = device {
            let session = AVCaptureSession()
            session.sessionPreset = .medium
            if let input = try? AVCaptureDeviceInput(device: device) {
                session.addInput(input)
                self.session = session
            }
        }
        CameraManager.shared.setPreviewActive(true)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true

        if let session = session {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = CGRect(x: 0, y: 0, width: 320, height: 240)
            previewLayer.videoGravity = .resizeAspect
            view.layer = previewLayer

            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
    }

    static func dismantleNSView(_ nsView: NSView, coordinator: ()) {
        if let previewLayer = nsView.layer as? AVCaptureVideoPreviewLayer,
           let session = previewLayer.session {
            session.stopRunning()

            for input in session.inputs {
                session.removeInput(input)
            }
            for output in session.outputs {
                session.removeOutput(output)
            }
        }

        CameraManager.shared.setPreviewActive(false)
    }
}