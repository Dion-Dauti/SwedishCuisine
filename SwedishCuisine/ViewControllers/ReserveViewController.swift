//
//  ReserveViewController.swift
//  SwedishCuisine
//
//  Created by Dion Dauti on 2024-02-28.
//

import UIKit

class ReserveViewController: UIViewController {

    @IBOutlet var numberOfGuests: UILabel!
    @IBOutlet var stepper: UIStepper!
    @IBOutlet var date: UIDatePicker!
    
    @IBOutlet weak var tableNumber: UILabel!
    @IBOutlet weak var decrementButton: UIButton!
    @IBOutlet weak var incrementButton: UIButton!

    @IBOutlet weak var fromTime: UIDatePicker!
    
    @IBOutlet weak var untilTime: UIDatePicker!
    // Set initial value
    private var currentValue = 1
    
    // Confirm Button
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var dateStack: UIStackView!
    @IBOutlet weak var timeStack: UIStackView!
    @IBOutlet weak var tableStack: UIStackView!
    @IBOutlet weak var stackView: UIStackView!    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        styleStackView(stackView)
        styleStackView(dateStack)
        styleStackView(timeStack)
        styleStackView(tableStack)
        
        confirmButton.layer.cornerRadius = 10
        

        confirmButton.backgroundColor = UIColor(red: 254/255.0, green: 204/255.0, blue: 2/255.0, alpha: 1.0)
    }
    
    @IBAction func decrementTapped(_ sender: UIButton) {
        // Prevent going below 1
        currentValue = max(1, currentValue - 1)
            updateTableLabel()
    }
    @IBAction func incrementTapped(_ sender: UIButton) {
        // Prevent going above 20
        currentValue = min(20, currentValue + 1)
        updateTableLabel()
    }
    @IBAction func stepperTapped(_ sender: UIStepper) {

        numberOfGuests.text = Int(sender.value).description
        
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        // Use a default table if invalid
        let tableNumber = Int(tableNumber.text!) ?? 1
            let reservationDate = date.date
            let startTime = fromTime.date
            let endTime = untilTime.date
            let numberOfSeats = Int(numberOfGuests.text!) ?? 1

            let databaseHelper = DatabaseHelper()

            if databaseHelper.hasConflictingBooking(tableNumber: tableNumber, reservationDate: reservationDate, startTime: startTime, endTime: endTime) {
                // Show the alert
                let alert = UIAlertController(title: "Conflict", message: "Reservation conflicts with existing booking", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                present(alert, animated: true)
            } else {
                if databaseHelper.insertBooking(tableNumber: tableNumber, seats: numberOfSeats, reservationDate: reservationDate, startTime: startTime, endTime: endTime) {
                    NotificationCenter.default.post(name: Notification.Name("BookingCreated"), object: nil)

                    // Show success alert
                    let alert = UIAlertController(title: "Success", message: "Reservation booked successfully!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    present(alert, animated: true)
                } else {
                    // Error handling
                    let alert = UIAlertController(title: "Error", message: "Failed to create reservation.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    present(alert, animated: true)
                }
            }
        }
    private func updateTableLabel() {
        tableNumber.text = "\(currentValue)"
    }
    
    func styleStackView(_ stackView: UIStackView) {
        stackView.layer.borderWidth = 2.0
        stackView.layer.borderColor = UIColor(red: 0.0/255.0, green: 106.0/255.0, blue: 167.0/255.0, alpha: 1.0).cgColor
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layer.cornerRadius = 10
    }
    
}
