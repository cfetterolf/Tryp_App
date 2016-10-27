//
//  PopUpViewController.swift
//  Tryp
//
//  Created by Chris Fetterolf on 10/9/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit
import Parse

class PopUpViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        
        self.showAnimate()
        var timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(PopUpViewController.update), userInfo: nil, repeats: false)
    
    }
    
    func update() {
        self.removeAnimate()
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.view.alpha = 0.0;
            }, completion: {(finished : Bool) in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
        //self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    

}
