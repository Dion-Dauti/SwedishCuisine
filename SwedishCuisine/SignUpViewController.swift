//
//  SignUpViewController.swift
//  SwedishCuisine
//
//  Created by Dion Dauti on 2024-02-27.
//

import UIKit


class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    let databaseHelper = DatabaseHelper()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginTapped(_ sender: Any) {
        performSegue(withIdentifier: "ToLoginFromSignUp", sender: nil)
    }
    
    @IBAction func createAccount(_ sender: Any) {
        // 1. Get user input
        guard let username = usernameTextField.text, !username.isEmpty else {
            showAlert(title: "Missing Username", message: "Please enter a username.")
            return
        }

        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Missing Email", message: "Please enter an email.")
            return
        }

        // Validate email format using a regular expression
        if !isValidEmail(email) {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }

        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Missing Password", message: "Please enter a password.")
            return
        }

        // 2. Hash the password
        let passwordHash = databaseHelper.hashPassword(password)

        // 3. Attempt to insert user into the database
        if databaseHelper.insertUser(username: username, email: email, passwordHash: passwordHash) {
            showAlert(title: "Success", message: "Account created! You can now log in.")
            performSegue(withIdentifier: "ToLoginFromSignUp", sender: nil)
        } else {
            showAlert(title: "Error", message: "Failed to create an account. Please try again.")
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    
        private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
