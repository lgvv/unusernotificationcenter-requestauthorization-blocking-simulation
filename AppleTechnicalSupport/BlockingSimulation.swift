//
//  AppleTechnicalSupportApp.swift
//  AppleTechnicalSupport
//
//  Created by LeeGeonWoo on 10/29/25.
//

import UIKit
import SwiftUI

struct BlockingSimulationView: View {
    var body: some View {
        List {
            Section("ServiceOnCompletion") {
                let service = ServiceOnCompletion()
                RowContentView(title: "Run Main", tc: "TC-ServiceOnCompletion-Main-001") { service.runMain() }
                RowContentView(title: "Run Global", tc: "TC-ServiceOnCompletion-Global-001") { service.runGlobal() }
                RowContentView(title: "Run Current", tc: "TC-ServiceOnCompletion-Current-001") { service.runCurrent() }
            }
            
            Section("ServiceOnMainCompletion") {
                let service = ServiceOnMainCompletion()
                RowContentView(title: "Run Main", tc: "TC-ServiceOnMainCompletion-Main-001") { service.runMain() }
                RowContentView(title: "Run Global", tc: "TC-ServiceOnMainCompletion-Global-001") { service.runGlobal() }
                RowContentView(title: "Run Current", tc: "TC-ServiceOnMainCompletion-Current-001") { service.runCurrent() }
            }
            
            Section("ServiceConcurreny") {
                let service = ServiceConcurreny()
                RowContentView(title: "Run Main", tc: "TC-ServiceConcurreny-Main-001") { service.runMain() }
                RowContentView(title: "Run Global", tc: "TC-ServiceConcurreny-Global-001") { service.runGlobal() }
                RowContentView(title: "Run Current", tc: "TC-ServiceConcurreny-Current-001") { service.runCurrent() }
            }
            
            Section("ServiceConcurrenyReturnOnMain") {
                let service = ServiceConcurrenyReturnOnMain()
                RowContentView(title: "Run Main", tc: "TC-ServiceConcurrenyReturnOnMain-Main-001") { service.runMain() }
                RowContentView(title: "Run Global", tc: "TC-ServiceConcurrenyReturnOnMain-Global-001") { service.runGlobal() }
                RowContentView(title: "Run Current", tc: "TC-ServiceConcurrenyReturnOnMain-Current-001") { service.runCurrent() }
            }
            
            Section("ServiceConcurrentConcurrenyReturnOnMain") {
                let service = ServiceConcurrentConcurrenyReturnOnMain()
                RowContentView(title: "Run Main", tc: "TC-ServiceConcurrentConcurrenyReturnOnMain-Main-001") { service.runMain() }
                RowContentView(title: "Run Global", tc: "TC-ServiceConcurrentConcurrenyReturnOnMain-Global-001") { service.runGlobal() }
                RowContentView(title: "Run Current", tc: "TC-ServiceConcurrentConcurrenyReturnOnMain-Current-001") { service.runCurrent() }
            }
        }
    }
    
    private struct RowContentView: View {
        var title: String
        var tc: String
        var action: () -> Void
        
        var body: some View {
            Button(title) {
                action()
            }
        }
    }
}

fileprivate final class ServiceOnCompletion {
    func runMain() { run(on: .main) }
    func runGlobal() { run(on: .global) }
    func runCurrent() { run(on: .current) }
    
    private func run(on thread: SystemAPI.ExecutionThread) {
        printWithCurrentThread("1️⃣ [\(#function)] Function started on:")
        let semaphore = DispatchSemaphore(value: 0)
        SystemAPI.run(on: thread) {
            printWithCurrentThread("2️⃣ [SystemAPI] Executed on:")
            semaphore.signal()
            printWithCurrentThread("3️⃣ [SystemAPI] semaphore.signal() called")
        }
        printWithCurrentThread("4️⃣ [\(#function)] Waiting for signal…")
        semaphore.wait()
        printWithCurrentThread("5️⃣ [\(#function)] Semaphore released, continuing execution")
    }
}

fileprivate final class ServiceOnMainCompletion {
    func runMain() { run(on: .main) }
    func runGlobal() { run(on: .global) }
    func runCurrent() { run(on: .current) }
    
    private func run(on thread: SystemAPI.ExecutionThread) {
        printWithCurrentThread("1️⃣ [\(#function)] Function started on:")
        let semaphore = DispatchSemaphore(value: 0)
        SystemAPI.runOnMainCompletion(on: thread) {
            printWithCurrentThread("2️⃣ [SystemAPI] Executed on:")
            semaphore.signal()
            printWithCurrentThread("3️⃣ [SystemAPI] semaphore.signal() called")
        }
        printWithCurrentThread("4️⃣ [\(#function)] Waiting for signal…")
        semaphore.wait()
        printWithCurrentThread("5️⃣ [\(#function)] Semaphore released, continuing execution")
    }
}

fileprivate final class ServiceConcurreny {
    func runMain() { run(on: .main) }
    func runGlobal() { run(on: .global) }
    func runCurrent() { run(on: .current) }
    
    private func run(on thread: SystemAPI.ExecutionThread) {
        printWithCurrentThread("1️⃣ [\(#function)] Function started on:")
        let semaphore = DispatchSemaphore(value: 0)
        switch thread {
        case .main:
            Task { @MainActor in
                printWithCurrentThread("2️⃣ [SystemAPI] Task running on thread:")
                _ = await SystemAPI.runConcurrncy(on: thread)
                printWithCurrentThread("3️⃣ [SystemAPI] Task completed with result")
                semaphore.signal()
            }
        case .global:
            Task { @concurrent in
                printWithCurrentThread("2️⃣ [SystemAPI] Task running on thread:")
                _ = await SystemAPI.runConcurrncy(on: thread)
                printWithCurrentThread("3️⃣ [SystemAPI] Task completed with result")
                semaphore.signal()
            }
        case .current:
            Task {
                printWithCurrentThread("2️⃣ [SystemAPI] Task running on thread:")
                _ = await SystemAPI.runConcurrncy(on: thread)
                printWithCurrentThread("3️⃣ [SystemAPI] Task completed with result")
                semaphore.signal()
            }
        }
        printWithCurrentThread("4️⃣ [\(#function)] Waiting for signal…")
        semaphore.wait()
        printWithCurrentThread("5️⃣ [\(#function)] Semaphore released, continuing execution")
    }
}

fileprivate final class ServiceConcurrenyReturnOnMain {
    func runMain() { run(on: .main) }
    func runGlobal() { run(on: .global) }
    func runCurrent() { run(on: .current) }
    
    private func run(on thread: SystemAPI.ExecutionThread) {
        let semaphore = DispatchSemaphore(value: 0)
        printWithCurrentThread("1️⃣ [\(#function)] Function started on:")
        switch thread {
        case .main:
            Task { @MainActor in
                printWithCurrentThread("2️⃣ [SystemAPI] Task running on thread:")
                _ = await SystemAPI.runConcurrncyReturnOnMain(on: thread)
                printWithCurrentThread("3️⃣ [SystemAPI] Task completed with result")
                semaphore.signal()
            }
        case .global:
            Task { @concurrent in
                printWithCurrentThread("2️⃣ [SystemAPI] Task running on thread:")
                _ = await SystemAPI.runConcurrncyReturnOnMain(on: thread)
                printWithCurrentThread("3️⃣ [SystemAPI] Task completed with result")
                semaphore.signal()
            }
        case .current:
            Task {
                printWithCurrentThread("2️⃣ [SystemAPI] Task running on thread:")
                _ = await SystemAPI.runConcurrncyReturnOnMain(on: thread)
                printWithCurrentThread("3️⃣ [SystemAPI] Task completed with result")
                semaphore.signal()
            }
        }
        printWithCurrentThread("4️⃣ [\(#function)] Waiting for signal…")
        semaphore.wait()
        printWithCurrentThread("5️⃣ [\(#function)] Semaphore released, continuing execution")
    }
}

fileprivate final class ServiceConcurrentConcurrenyReturnOnMain {
    func runMain() { run(on: .main) }
    func runGlobal() { run(on: .global) }
    func runCurrent() { run(on: .current) }
    
    private func run(on thread: SystemAPI.ExecutionThread) {
        let semaphore = DispatchSemaphore(value: 0)
        printWithCurrentThread("1️⃣ [\(#function)] Function started on:")
        switch thread {
        case .main:
            Task { @MainActor in
                printWithCurrentThread("2️⃣ [SystemAPI] Task running on thread:")
                _ = await SystemAPI.runConrruentConcurrncyReturnOnMain(on: thread)
                printWithCurrentThread("3️⃣ [SystemAPI] Task completed with result")
                semaphore.signal()
            }
        case .global:
            Task { @concurrent in
                printWithCurrentThread("2️⃣ [SystemAPI] Task running on thread:")
                _ = await SystemAPI.runConrruentConcurrncyReturnOnMain(on: thread)
                printWithCurrentThread("3️⃣ [SystemAPI] Task completed with result")
                semaphore.signal()
            }
        case .current:
            Task {
                printWithCurrentThread("2️⃣ [SystemAPI] Task running on thread:")
                _ = await SystemAPI.runConrruentConcurrncyReturnOnMain(on: thread)
                printWithCurrentThread("3️⃣ [SystemAPI] Task completed with result")
                semaphore.signal()
            }
        }
        printWithCurrentThread("4️⃣ [\(#function)] Waiting for signal…")
        semaphore.wait()
        printWithCurrentThread("5️⃣ [\(#function)] Semaphore released, continuing execution")
    }
}

fileprivate struct SystemAPI {
    enum ExecutionThread {
        case main
        case global
        case current
    }
    
    /// Executes a task asynchronously on the specified thread.
    /// Completion runs on the same thread as the task.
    static func run(on thread: ExecutionThread, _ completion: @escaping () -> Void) {
        let workItem = DispatchWorkItem {
            printWithCurrentThread("🍍 DispatchWorkItem performed by:")
            completion()
        }
        
        SystemAPI.perform(on: thread, workItem: workItem)
    }
    
    /// Executes a task asynchronously on the specified thread.
    /// Completion always runs on the main thread.
    static func runOnMainCompletion(on thread: ExecutionThread, _ completion: @escaping () -> Void) {
        let workItem = DispatchWorkItem {
            printWithCurrentThread("🍍 Concurrency performed by:")
            DispatchQueue.main.async {
                printWithCurrentThread("🍍 Concurrency return by:")
                completion()
            }
        }

        SystemAPI.perform(on: thread, workItem: workItem)
    }
    
    static private func perform(on thread: ExecutionThread, workItem: DispatchWorkItem) {
        switch thread {
        case .main:
            if Thread.isMainThread {
                workItem.perform()
            } else {
                DispatchQueue.main.async(execute: workItem)
            }

        case .global:
            DispatchQueue.global().async(execute: workItem)
        
        case .current:
            workItem.perform()
        }
    }
    
    static func runConcurrncy(on thread: ExecutionThread) async -> Void {
        printWithCurrentThread("🍍 Concurrency performed by:")
        return ()
    }
    
    static func runConcurrncyReturnOnMain(on thread: ExecutionThread) async -> Void {
        printWithCurrentThread("🍍 Concurrency performed by:")
        await MainActor.run {
            printWithCurrentThread("🍍 Concurrency return by:")
            return ()
        }
    }
    
    @concurrent
    static func runConrruentConcurrncy(on thread: ExecutionThread) async -> Void {
        printWithCurrentThread("🍍 Concurrency performed by:")
        return ()
    }
    
    @concurrent
    static func runConrruentConcurrncyReturnOnMain(on thread: ExecutionThread) async -> Void {
        printWithCurrentThread("🍍 concurrency performed by:")
        await MainActor.run {
            printWithCurrentThread("🍍 concurrency return by:")
            return ()
        }
    }
}

nonisolated
fileprivate func printWithCurrentThread(_ message: String) {
    print(message, Thread.current)
}

#Preview {
    BlockingSimulationView()
}
