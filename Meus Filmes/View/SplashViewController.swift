//
//  SplashViewController.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 27/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit
import Lottie

class SplashViewController: UIViewController {

    @IBOutlet weak var animationView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        animationView.play { finished in
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            let storyboard = UIStoryboard(name: "Filmes", bundle: nil)
            let initialViewController = storyboard.instantiateInitialViewController()
            window?.rootViewController = initialViewController
            window?.makeKeyAndVisible()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
