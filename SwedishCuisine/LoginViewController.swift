//
//  LoginViewController.swift
//  SwedishCuisine
//
//  Created by Dion Dauti on 2024-02-27.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    let databaseHelper = DatabaseHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 10
        loginButton.backgroundColor = UIColor(red: 254/255.0, green: 204/255.0, blue: 2/255.0, alpha: 1.0)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        // Hash the typed password for comparison
        let hashedPassword = databaseHelper.hashPassword(passwordField.text ?? "")
        
        // Check if credentials are right
        if databaseHelper.findUser(username: usernameField.text ?? "",
                                   passwordHash: hashedPassword)
        {
            performSegue(withIdentifier: "ToHomeFromLogin", sender: nil)
            usernameField.text = ""
            passwordField.text = ""
        }
        else {
            showAlert(title: "Error", message: "Incorrect username or password!")
        }
    }
    
    @IBAction func registertapped(_ sender: UIButton) {
        performSegue(withIdentifier: "ToSignUpFromLogin", sender: nil)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

