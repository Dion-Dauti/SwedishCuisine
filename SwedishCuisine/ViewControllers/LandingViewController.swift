//
//  LandingViewController.swift
//  SwedishCuisine
//
//  Created by Dion Dauti on 2024-02-27.
//

import UIKit

class LandingViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var createAccButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 10
        loginButton.backgroundColor = UIColor(red: 254/255.0, green: 204/255.0, blue: 2/255.0, alpha: 1.0)
        
        createAccButton.layer.cornerRadius = 10
        createAccButton.backgroundColor = UIColor(red: 0, green: 106/255.0, blue: 167/255.0, alpha: 1.0)
    }
    

    @IBAction func toSignUpTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "ToSignUpFromLanding", sender: nil)
    }
    
     @IBAction func toLoginTapped(_ sender: UIButton) {
         performSegue(withIdentifier: "ToLoginFromLanding", sender: nil)
     }
}
