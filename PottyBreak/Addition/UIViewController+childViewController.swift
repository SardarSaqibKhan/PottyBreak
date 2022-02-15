//
//  UIViewController+childViewController.swift
//  Vehicle Maintenance
//
//  Created by fahad on 12/09/2018.
//  Copyright © 2018 EYCON. All rights reserved.
//

import UIKit

extension UIViewController
{
    
    func addChildVC( _ child: UIViewController, animated: Bool = false) -> UIViewController {
        
        if animated {
            child.view.alpha = 0
        }
        
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                child.view.alpha = 1
            }
        }
        
        return child
    }
    
    func removeFromParent(_ animated: Bool = false) {
        
        func remove() {
//            self.willMove(toParentViewController: nil)
//            view.removeFromSuperview()
//            removeFromParent()
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.alpha = 0
            }) { (_) in
                remove()
            }
        } else {
            remove()
        }
        
        
    }
}





















