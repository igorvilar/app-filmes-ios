//
//  ViewControler.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 29/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit


extension UIViewController {
    
    func simpleAlert(title: String, message: String, dismiss: Bool, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = SimpleAlert.alertWithTitle(title, andMessage: message, withCompletion: { _ in
                if (dismiss) {
                    self.dismiss(animated: true, completion: nil)
                }
                completion?()
            })
            SimpleAlert.show(alert, onView: self)
        }
    }
}

extension UIActivityIndicatorView {
    func startLoad (start: Bool) {
        DispatchQueue.main.async {
            if start {
                self.startAnimating()
            } else {
                self.stopAnimating()
            }
        }
    }
}
