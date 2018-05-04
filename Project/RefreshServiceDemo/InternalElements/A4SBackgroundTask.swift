//
//  A4SBackgroundTask.swift
//  RefreshServiceDemo
//
//  Created by Arkadi Yoskovitz on 5/4/18.
//  Copyright © 2018 Arkadi Yoskovitz. All rights reserved.
//

import UIKit

open class A4SBackgroundTask
{
    // MARK: - Private Properties
    private var taskIdentifier : UIBackgroundTaskIdentifier

    // MARK: - Public Properties
    let application : A4SApplicationBackgroundTaskProtocol
    
    // MARK: - Initialization
    // =================================================================================================================
    public init(application: A4SApplicationBackgroundTaskProtocol)
    {
        self.application    = application
        self.taskIdentifier = UIBackgroundTaskInvalid
    }
    
    // MARK: - Object lifecycle
    // =================================================================================================================
    deinit
    {
        //  If deinit didn't happen you have a ref cycle
        print("📢 \(type(of: self)) deint successfully")
    }
    
    // MARK: - Task activation methods
    // =================================================================================================================
    public func beginBackgroundTask(named taskName: String?)
    {
        guard taskIdentifier == UIBackgroundTaskInvalid else { return }
        taskIdentifier = application.beginBackgroundTask(withName: taskName, expirationHandler: {
            
            self.endBackgroundTask()
        })
    }
    
    public func endBackgroundTask()
    {
        guard taskIdentifier != UIBackgroundTaskInvalid else { return }
        application.endBackgroundTask(taskIdentifier)
        taskIdentifier = UIBackgroundTaskInvalid
    }
}
