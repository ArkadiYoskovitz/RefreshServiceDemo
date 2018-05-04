//
//  ViewController.swift
//  RefreshServiceDemo
//
//  Created by Arkadi Yoskovitz on 5/4/18.
//  Copyright © 2018 Arkadi Yoskovitz. All rights reserved.
//

import UIKit

class ViewController : UIViewController {

    var testService : A4SBlockRefreshService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        testService = A4SBlockRefreshService(taskDelayInterval: TimeInterval(5.0)) { [weak self] in
            
            guard let strongSelf = self else { return }
            
            print("§±±±±§ §±±±±§ §±±±±§ §±±±±§ §±±±±§ : >>>>> : timestamp: \(Date()), backgroundTaskName: \(strongSelf.testService.backgroundTaskName)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
