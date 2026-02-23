# Investigating Rare Bugs in UNUserNotificationCenter.requestAuthorization on iOS

## Overview

This repository demonstrates a rare issue with `UNUserNotificationCenter.current().requestAuthorization` on iOS.  
The problem manifests when the completion handler for authorization requests **fails to execute**, creating a deadlock-like suspension state.

The project uses `BlockingSimulationView` and related components to reproduce and analyze these behaviors, particularly regarding thread execution and MainActor isolation.

---

## Experimental Environment

| Item | Value |
|------|-------|
| Xcode | 26.0.1 (17A400) |
| Swift Language Version | Swift 6 |
| Default Actor Isolation | MainActor |
| Swift Concurrency Checking | Complete |

---

## BlockingSimulation Console Log

Logs compiled from `BlockingSimulationView`. Each test case (`tc`) maps directly to a corresponding identifier in the source code.

### ServiceOnCompletion

| Test Case | Behavior |
|-----------|----------|
| TC-ServiceOnCompletion-Main-001 | All steps execute sequentially on the main thread. Completes normally. |
| TC-ServiceOnCompletion-Global-001 | Dispatch work item runs on a background thread. Semaphore signaling and completion succeed. |
| TC-ServiceOnCompletion-Current-001 | Similar to Main-001. All execution on the main thread proceeds correctly. |

### ServiceOnMainCompletion

| Test Case | Behavior |
|-----------|----------|
| TC-ServiceOnMainCompletion-Main-001 | Execution **stalls** at the waiting stage on the main thread. |
| TC-ServiceOnMainCompletion-Global-001 | Starts on main thread but **stalls** while concurrency executes on a background thread. |
| TC-ServiceOnMainCompletion-Current-001 | Main thread execution **halts** at the waiting point. |

### ServiceConcurrency

All three variants (Main, Global, Current) exhibit **incomplete execution flows** — execution stops at the waiting stage without proceeding further.

### ServiceConcurrencyReturnOnMain

Similar blocking patterns appear across all three configurations, with execution **suspended at the waiting point**.

### ServiceConcurrentConcurrencyReturnOnMain

| Test Case | Behavior |
|-----------|----------|
| TC-ServiceConcurrentConcurrencyReturnOnMain-Main-001 | Incomplete execution flow. |
| TC-ServiceConcurrentConcurrencyReturnOnMain-Global-001 | Task executes on a background thread with concurrency completion. |
| TC-ServiceConcurrentConcurrencyReturnOnMain-Current-001 | Incomplete execution flow. |

### Analysis

Normal execution proceeds sequentially through all steps, with the semaphore signal enabling continuation.  
However, certain instances **fail to reach expected subsequent steps**.

While theoretically straightforward, this behavior appears influenced by Apple's internal implementation.  
Cases showing incomplete execution flows represent the **core manifestation of the issue**.

---

## MockSimulation

This component emulates Apple's system API behavior to reproduce potential bug scenarios.  
The design emphasizes **thread-related behaviors**, as Apple's documentation indicates that `requestAuthorization` completion handlers may execute on background threads.

| Test Case | Behavior |
|-----------|----------|
| TC-MockSimulation-Main-001 | Execution **halts** at the waiting stage. |
| TC-MockSimulation-Global-001 | Background thread execution completes with proper signaling and semaphore release. |

> **Note:** TC-MockSimulation-Global-001 produces a diagnostic warning about calling a MainActor-isolated method from a nonisolated synchronous context.

---

## TechnicalSupportSampleView

This section illustrates where the issue occurs in actual code. Reproduction remains difficult due to very low frequency, but recent user reports confirm its appearance in real usage scenarios. The project includes Objective-C portions, which may hide certain diagnostic issues.

> **Critical Finding:** When this issue occurs, using official Swift Concurrency documentation code results in `await` failing to suspend, causing **immediate execution continuation** instead of proper asynchronous behavior.
