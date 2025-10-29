//
//  TechnicalSupportSampleView.swift
//  AppleTechnicalSupport
//
//  Created by LeeGeonWoo on 10/29/25.
//

import UIKit
import SwiftUI

final class SystemAuthorizationService {
    func reqeustAuthorization() {
        UNUserNotificationCenter.requestAuthorization()
    }
}

extension UNUserNotificationCenter {
    @objc
    class func requestAuthorization() {
        let semaphore = DispatchSemaphore(value: 0)
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge, .provisional]) { value, error in
            semaphore.signal() // ❗️ Callback never invoked in some cases
        }
        semaphore.wait()
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    class func requestAuthorizationAsync() {
        Task {
            let center = UNUserNotificationCenter.current()
            do {
                if try await center.requestAuthorization() == true {
                    // Authorized
                } else {
                    // Not authorized
                }
            } catch {
                // Handle error
            }
        }
        // ❗️ The await does not suspend; execution continues immediately
    }
}

struct TechnicalSupportSampleView: View {
    var body: some View {
        Button("Button") {
            let service = SystemAuthorizationService()
            service.reqeustAuthorization()
        }
    }
}
