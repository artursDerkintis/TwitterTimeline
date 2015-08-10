//
//  ViewController.swift
//  TwitterTimeline
//
//  Created by Arturs Derkintis on 8/10/15.
//  Copyright © 2015 Starfly. All rights reserved.
//

import UIKit
let placeholderPR = UIImage(named: "no_image_pr")
let placeholderFull = UIImage(named: "no_image_Content")
var homeController : ViewController?
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        homeController = self
        if User.currentUser != nil {
            openTimeLine()
        }else{
            TwitterClient.sharedInstance.loginWithCompletion { (user, error) -> () in
                if error == nil{
                self.openTimeLine()
                }
            }
        }

        
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    func openTimeLine(){
        let timeline = SFSmartCollectionController()
        timeline.view.frame = self.view.bounds
        timeline.view.autoresizingMask = sfMaskBoth
        self.view.addSubview(timeline.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

