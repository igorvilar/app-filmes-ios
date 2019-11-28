//
//  SimpleAlert.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 27/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit

class SimpleAlert: NSObject {

    static func show(_ alert: UIAlertController, onView view: UIViewController) {
        view.present(alert, animated: true)
    }

    static func alertWithTitle(_ title: String, andMessage message: String, withCompletion handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: handler)
        alert.addAction(action)
        return alert
    }

}
