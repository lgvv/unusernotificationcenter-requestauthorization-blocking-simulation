//
//  MockSimulationView.swift
//  AppleTechnicalSupport
//
//  Created by LeeGeonWoo on 10/29/25.
//

import SwiftUI
import UIKit

private class SystemAuthorization {
    func requestAuthorization(isRunOnMainThread: Bool) {
        if isRunOnMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.perform()
            }
        } else {
            DispatchQueue.global().async { [weak self] in
                self?.perform()
            }
        }
    }
    
    private func perform() {
        printWithCurrentThread("1️⃣ [\(#function)] Function started on:")
        let semaphore = DispatchSemaphore(value: 0)
        MockNotificationCenter.current().requestAuthorization { result, error in
            printWithCurrentThread("2️⃣ [SystemAPI] Executed on:")
            semaphore.signal()
            printWithCurrentThread("3️⃣ [SystemAPI] semaphore.signal() called")
        }
        printWithCurrentThread("4️⃣ [\(#function)] Waiting for signal…")
        semaphore.wait()
        printWithCurrentThread("5️⃣ [\(#function)] Semaphore released, continuing execution")
    }
}

struct MockSimulationView: View {
    private var systemAuthorization = SystemAuthorization()
    
    var body: some View {
        VStack(spacing: 30) {
            Button("TC-MockSimulation-Main-001") {
                systemAuthorization.requestAuthorization(isRunOnMainThread: true)
            }
            
            Button("TC-MockSimulation-Global-001") {
                systemAuthorization.requestAuthorization(isRunOnMainThread: false)
            }
        }
    }
}

fileprivate enum MockAuthorizationOptions {}
    
fileprivate final class MockNotificationCenter {
    private static var center = MockNotificationCenter()
    
    static func current() -> MockNotificationCenter {
        return center
    }
    
    func requestAuthorization(
        options: [MockAuthorizationOptions] = [],
        completionHandler: @escaping (Bool, (any Error)?) -> Void
    ) {
        DispatchQueue.main.async {
            let alertController = MockAlertController(completionHandler: completionHandler)
            Utils.show(alert: alertController)
        }
    }
    
}

fileprivate enum MockAuthorizationStatus {}

fileprivate final class MockAlertController: UIAlertController {
    typealias CompletionHandler = (Bool, (any Error)?) -> Void
    
    private var isGranted: Bool = false
    private var completionHandler: CompletionHandler?
    
    init(completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
        super.init(nibName: nil, bundle: nil)
        printWithCurrentThread("MockAlertController initialized")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        printWithCurrentThread("MockAlertController called viewDidLoad")
        
        self.title = "MockNotificationPermissionTitle"
        self.message = "MockNotificationPermissionMessage"
        
        let confirmAction = UIAlertAction(title: "confirm", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.isGranted = true
            completionHandler?(isGranted, nil)
            completionHandler = nil
        }
        self.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { [weak self] _ in
            guard let self else { return }
            self.isGranted = false
            completionHandler?(isGranted, nil)
            completionHandler = nil
        }
        self.addAction(cancelAction)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        printWithCurrentThread("MockAlertController called viewDidDisappear")
        
        completionHandler?(isGranted, nil)
        completionHandler = nil
    }
}

fileprivate enum Utils {
    @MainActor
    static func show(alert rootViewController: UIViewController) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(rootViewController, animated: false)
        }
    }
}

nonisolated
fileprivate func printWithCurrentThread(_ message: String) {
    print(message, Thread.current)
}
