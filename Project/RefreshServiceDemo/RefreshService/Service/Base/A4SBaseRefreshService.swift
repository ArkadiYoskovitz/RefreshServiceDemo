//
//  A4SBaseRefreshService.swift
//  RefreshServiceDemo
//
//  Created by Arkadi Yoskovitz on 5/4/18.
//  Copyright © 2018 Arkadi Yoskovitz. All rights reserved.
//

import UIKit

open class A4SBaseRefreshService
{
    // MARK: - Types
    private enum StorageKeys : String , CustomStringConvertible {
        case lostUserFocusKey = "A4SLostUserFocusKey"
        var description: String { return rawValue }
    }
    
    // MARK: - Private Properties
    private let   refreshQueue : DispatchQueue
    private let  dispatchTimer : A4SDispatchTimer
    private let backgroundTask : A4SBackgroundTask
    
    private var    _taskDelayInterval : TimeInterval
    private var lostUserFocusInterval : TimeInterval {
        get { return storage.double(forKey: StorageKeys.lostUserFocusKey.description) }
        set { storage.set(newValue, forKey: StorageKeys.lostUserFocusKey.description)
            storage.synchronize()
        }
    }
    
    // MARK: - Public Properties
    public var backgroundTaskName : String
    public var taskDelayInterval  : TimeInterval {
        set {
            refreshQueue.async(flags: .barrier) {
                self._taskDelayInterval = newValue
            }
        }
        get {
            var taskDelay : TimeInterval!
            refreshQueue.sync {
                taskDelay = _taskDelayInterval
            }
            return taskDelay
        }
    }
    
    public var shouldPreformRefreshAction : Bool {
        
        let            refreshInterval = taskDelayInterval
        let   currentTimestampInterval = Date().timeIntervalSince1970
        let focusLossTimestampInterval = lostUserFocusInterval
        
        let timeLeft = currentTimestampInterval - focusLossTimestampInterval
        
        let shouldPreformAction = timeLeft > refreshInterval ? true : false
        return shouldPreformAction
    }
    
    // MARK: - Open Properties
    open var storage : UserDefaults {
        
        return UserDefaults.standard
    }
    
    // MARK: - Initialization
    // =================================================================================================================
    public required init(application: A4SApplicationBackgroundTaskProtocol = UIApplication.shared, taskDelayInterval delayInterval: TimeInterval = TimeInterval(15))
    {
        let aQueue = DispatchQueue(label: "RKRefreshService.queue", qos: .userInitiated, attributes: .concurrent)
        self.refreshQueue   = aQueue
        self.dispatchTimer  = A4SDispatchTimer(queue: aQueue)
        self.backgroundTask = A4SBackgroundTask(application: application)
        self.backgroundTaskName = "RKRefreshService.BackgroundTask"
        self._taskDelayInterval = delayInterval
        self.addNotificationObservers(for: application)
    }
    
    // MARK: - Object lifecycle
    // =================================================================================================================
    deinit
    {
        removeNotificationObservers()
        //  If deinit didn't happen you have a ref cycle
        print("📢 \(type(of: self)) deint successfully")
    }
    
    // MARK - NotificationCenterObservers
    // =================================================================================================================
    private func addNotificationObservers(for application: A4SApplicationBackgroundTaskProtocol)
    {
        // Register to receive Background Enter / Leave notifications
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(didEnterBackground(with:)), name: .UIApplicationDidEnterBackground, object: application)
        center.addObserver(self, selector: #selector(didBecomeActive(with:))   , name: .UIApplicationDidBecomeActive   , object: application)
    }
    
    private func removeNotificationObservers()
    {
        // To support iOS < 9.0 and macOS < 10.11, NotificationCenter observers must be removed.
        // (Or a crash may result.)
        // Reference: https://developer.apple.com/reference/foundation/notificationcenter/1415360-addobserver
        let center = NotificationCenter.default
        center.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        center.removeObserver(self, name: .UIApplicationDidBecomeActive   , object: nil)
    }
    
    // MARK - Handling Notifications
    @objc private func didEnterBackground(with notification: NSNotification)
    {
        /// Begin background task
        backgroundTask.beginBackgroundTask(named: backgroundTaskName)
        
        /// Update lost user focus timestamp
        lostUserFocus()
        
        /// Set timer interval for needed time
        dispatchTimer.schedule(deadline: .now(), repeating: .seconds(1), leeway: .seconds(0))
        
        /// Configure timer event handler block
        dispatchTimer.setEventHandler { [weak self] in self?.triggerRefreshAction() }
        
        /// Activate timer
        dispatchTimer.resume()
    }
    
    @objc private func didBecomeActive(with notification: NSNotification)
    {
        /// Disable timer block
        dispatchTimer.suspend()
    }
    
    // MARK: - Handling user focus
    private  func lostUserFocus()
    {
        lostUserFocusInterval = Date().timeIntervalSince1970
    }
    
    // MARK: - Handling service refresh action
    private func triggerRefreshAction()
    {
        guard shouldPreformRefreshAction else { return }
        preformRefreshAction()
        dispatchTimer.suspend()
        backgroundTask.endBackgroundTask()
    }
    
    open func preformRefreshAction()
    {
        /// for subclassers
    }
}
