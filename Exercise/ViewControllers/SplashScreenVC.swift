//
//  SplashScreenVC.swift
//  Exercise
//
//  Created by dvir on 17/01/2019.
//  Copyright © 2019 dvir. All rights reserved.
//

import Lottie
import UIKit

class SplashScreenVC: UIViewController {
    //MARK: Variables Declaration
        let animation = LOTAnimationView(name: "loading")
    
    //MARK: ViewController Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        animation.animationSpeed = 0.8
        animation.contentMode = .scaleAspectFit
        animation.frame = view.bounds
        animation.center = view.center
        view.addSubview(animation)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animation.play{(finished) in
            if AppAuthentication.shared.getCurrentUserID() != nil{
                self.performSegue(withIdentifier: "gotomain", sender: nil)
            }else{
                self.performSegue(withIdentifier: "gotologin", sender: nil)
            }
        }
       
    }

}
