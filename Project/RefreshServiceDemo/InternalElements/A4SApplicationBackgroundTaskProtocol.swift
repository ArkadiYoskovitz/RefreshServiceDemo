//
//  A4SApplicationBackgroundTaskProtocol.swift
//  RefreshServiceDemo
//
//  Created by Arkadi Yoskovitz on 5/4/18.
//  Copyright © 2018 Arkadi Yoskovitz. All rights reserved.
//

import UIKit

public protocol A4SApplicationBackgroundTaskProtocol
{
    var applicationState : UIApplicationState { get }
    
    func beginBackgroundTask(withName taskName: String?, expirationHandler handler: (() -> Swift.Void)?) -> UIBackgroundTaskIdentifier
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier)
}

extension UIApplication : A4SApplicationBackgroundTaskProtocol { }
