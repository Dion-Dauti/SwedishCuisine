import UIKit

class BookingsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource  {

    var bookings: [Booking] = []
    @IBOutlet var bookingTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookingTableView.delegate = self
        bookingTableView.dataSource = self
        loadBookings()
        NotificationCenter.default.addObserver(self, selector: #selector(loadBookings), name: Notification.Name("BookingCreated"), object: nil)

    }

    @objc func loadBookings() {
        let databaseHelper = DatabaseHelper()
        bookings = databaseHelper.fetchBookings()
        bookingTableView.reloadData()
    }

   

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookings.count
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookingCell", for: indexPath) as! BookingViewCell

        let booking = bookings[indexPath.row]

        cell.tableNumber.text = " \(booking.tableNumber)"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        cell.date.text = dateFormatter.string(from: booking.reservationDate)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        cell.time.text = "\(timeFormatter.string(from: booking.startTime)) - \(timeFormatter.string(from: booking.endTime))"

        cell.seats.text = " \(booking.seats)"

        return cell
    }
}
