//
//  SignUpViewController.swift
//  SwedishCuisine
//
//  Created by Dion Dauti on 2024-02-27.
//

import UIKit

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginTapped(_ sender: Any) {
        performSegue(withIdentifier: "ToLoginFromSignUp", sender: nil)
    }
    
    @IBAction func createAccount(_ sender: Any) {
        performSegue(withIdentifier: "ToLoginFromSignUp", sender: nil)
        
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
