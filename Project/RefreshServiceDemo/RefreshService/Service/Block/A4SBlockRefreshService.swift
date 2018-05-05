//
//  A4SBlockRefreshService.swift
//  RefreshServiceDemo
//
//  Created by Arkadi Yoskovitz on 5/4/18.
//  Copyright © 2018 Arkadi Yoskovitz. All rights reserved.
//

import UIKit

class A4SBlockRefreshService : A4SBaseRefreshService
{
    // MARK: - Typealias
    public typealias EventHandler = @convention(block) () -> Swift.Void
    
    // MARK: - Private Properties
    var refreshServiceBlock : EventHandler?
    
    // MARK: - Initialization
    // =================================================================================================================
    public required init(application: A4SApplicationBackgroundTaskProtocol = UIApplication.shared, taskDelayInterval delayInterval: TimeInterval = TimeInterval(15))
    {
        self.refreshServiceBlock = nil
        super.init(application: application, taskDelayInterval: delayInterval)
    }
    
    public init(application: A4SApplicationBackgroundTaskProtocol = UIApplication.shared, taskDelayInterval delayInterval: TimeInterval = TimeInterval(15) , handler: @escaping EventHandler)
    {
        self.refreshServiceBlock = handler
        super.init(application: application, taskDelayInterval: delayInterval)
    }
    
    // MARK: - Object lifecycle
    // =================================================================================================================
    deinit
    {
        //  If deinit didn't happen you have a ref cycle
        print("📢 \(type(of: self)) deint successfully")
    }
    
    // MARK: - Override elements - Methods
    // =================================================================================================================
    override func preformRefreshAction()
    {
        refreshServiceBlock?()
    }
}
