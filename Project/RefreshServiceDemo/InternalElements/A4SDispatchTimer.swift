//
//  A4SDispatchTimer.swift
//  RefreshServiceDemo
//
//  Created by Arkadi Yoskovitz on 5/4/18.
//  Copyright © 2018 Arkadi Yoskovitz. All rights reserved.
//

import Foundation
import Dispatch

open class A4SDispatchTimer : NSObject , DispatchSourceProtocol
{
    // MARK: - Typealias
    public typealias EventHandler = @convention(block) () -> Swift.Void
    
    // MARK: - Private properties
    private let timer : DispatchSourceTimer
    private let lock  : NSLock
    private var didResume : Bool
    
    
    // MARK: - Public  properties
    open var handle : UInt { return timer.handle }
    open var mask   : UInt { return timer.mask   }
    open var data   : UInt { return timer.data   }
    
    open var isCancelled : Bool {
        return timer.isCancelled
    }
    
    // MARK: - Initialization
    // =================================================================================================================
    public init(queue: DispatchQueue)
    {
        self.lock  = NSLock()
        self.didResume = false
        self.timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
        super.init()
    }
    
    // MARK: - Object lifecycle
    // =================================================================================================================
    deinit
    {
        // ensure that the timer is cancelled and resumed before deiniting
        // (trying to deconstruct a suspended DispatchSource will fail)
        timer.cancel()
        lock.withRKCriticalScope {
            guard !didResume else { return }
            timer.resume()
        }
    }
    
    // MARK: - DispatchSourceTimer methods
    // =================================================================================================================
    public func setEventHandler(qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], handler: @escaping EventHandler)
    {
        timer.setEventHandler(qos: qos, flags: flags, handler: handler)
    }
    
    public func setEventHandler(handler: DispatchWorkItem)
    {
        timer.setEventHandler(handler: handler)
    }
    
    public func setCancelHandler(qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], handler: DispatchSourceProtocol.DispatchSourceHandler?)
    {
        timer.setCancelHandler(qos: qos, flags: flags, handler: handler)
    }
    
    public func setCancelHandler(handler: DispatchWorkItem)
    {
        timer.setCancelHandler(handler: handler)
    }
    
    public func setRegistrationHandler(qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], handler: DispatchSourceProtocol.DispatchSourceHandler?)
    {
        timer.setRegistrationHandler(qos: qos, flags: flags, handler: handler)
    }
    
    public func setRegistrationHandler(handler: DispatchWorkItem)
    {
        timer.setRegistrationHandler(handler: handler)
    }
    
    public func schedule(deadline: DispatchTime = DispatchTime.now(), repeating interval: DispatchTimeInterval = DispatchTimeInterval.seconds(1), leeway: DispatchTimeInterval = DispatchTimeInterval.seconds(0))
    {
        timer.schedule(deadline: deadline, repeating: interval, leeway: leeway)
    }
    
    public func activate()
    {
        
    }
    
    public func cancel()
    {
        timer.cancel()
    }
    
    public func resume()
    {
        lock.withRKCriticalScope {
            guard !didResume else { return }
            timer.resume()
            didResume = true
        }
    }
    
    public func suspend()
    {
        lock.withRKCriticalScope {
            
            guard didResume else { return }
            timer.suspend()
            didResume = false
        }
    }
}

public extension NSLock {
    
    /// Convenience API to execute block after acquiring the lock
    ///
    /// - Parameter block: the block to run
    /// - Returns: returns the return value of the block
    public func withRKCriticalScope<T>(block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}

public extension NSRecursiveLock {
    
    /// Convenience API to execute block after acquiring the lock
    ///
    /// - Parameter block: the block to run
    /// - Returns: returns the return value of the block
    public func withRKCriticalScope<T>(block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
