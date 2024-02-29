//
//  DBManager.swift
//  SwedishCuisine
//
//  Created by Dion Dauti on 2024-02-27.
//

import Foundation
import SQLite3
import CryptoKit

class DatabaseHelper {

    
    private var db: OpaquePointer?
    private let dbPath = "/Users/dadi222/Documents/SwedishCuisine.db"
    static var currentUsername: String?
    static var accessedUsername: String {
        get {
            return currentUsername ?? ""
        }}
    init() {
        // Open the database
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Error opening database")
        } else {
            createTablesIfDontExist()
        }
    }

    private func createTablesIfDontExist() {
        let createCustomersTableQuery = """
            CREATE TABLE IF NOT EXISTS customers (
                customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT,
                email TEXT,
                password TEXT
            );
            """

        if sqlite3_exec(db, createCustomersTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating Customers table")
        }
        
    }

    func insertUser(username: String,email: String, passwordHash: String) -> Bool {
        let query = "INSERT INTO Customers (username,email,password) VALUES (?,?,?)"
        var statement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                    sqlite3_bind_text(statement, 1, (username as NSString).utf8String, -1,nil)
                    sqlite3_bind_text(statement, 2, (email as NSString).utf8String, -1, nil)
                    sqlite3_bind_text(statement, 3, (passwordHash as NSString).utf8String, -1, nil)

                    if sqlite3_step(statement) == SQLITE_DONE {
                        sqlite3_finalize(statement)
                        return true
                    } else {
                        print("Error inserting user: \(String(cString: sqlite3_errmsg(db)))")
                        sqlite3_finalize(statement)
                        return false
                    }
                } else {
                    print("Error preparing insert statement: \(String(cString: sqlite3_errmsg(db)))")
                    return false
                }
    }

    func findUser(username: String, passwordHash: String) -> Bool {
        let query = "SELECT costumer_id FROM customers WHERE username = ? AND password = ?"
        var statement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (passwordHash as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) == SQLITE_ROW {
                DatabaseHelper.currentUsername = username
                sqlite3_finalize(statement)
                return true // User found
            } else {
                sqlite3_finalize(statement)
                return false // User not found
            }
        } else {
            print("Error preparing login statement: \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
    }
    
    func fetchMenuItems() -> [MenuItem] {
            let query = "SELECT name, price, image FROM menuItems" 
            var statement: OpaquePointer? = nil
            var menuItems: [MenuItem] = []

            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let name = String(cString: sqlite3_column_text(statement, 0))
                    let price = sqlite3_column_double(statement, 1)
                    let image = String(cString: sqlite3_column_text(statement, 2))

                    let menuItem = MenuItem(name: name, price: price, image: image)
                    menuItems.append(menuItem)
                }
            } else {
                print("Error preparing menu item selection: \(String(cString: sqlite3_errmsg(db)))")
            }

            sqlite3_finalize(statement)
            return menuItems
        }
    
    func hasConflictingBooking(tableNumber: Int, reservationDate: Date, startTime: Date, endTime: Date) -> Bool {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let formattedDate = dateFormatter.string(from: reservationDate)

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            let formattedStartTime = timeFormatter.string(from: startTime)
            let formattedEndTime = timeFormatter.string(from: endTime)

            let query = """
                SELECT EXISTS(
                    SELECT 1 FROM bookings
                    WHERE table_number = ?
                    AND reservation_date = ?
                    AND (
                        (start_time <= ? AND end_time > ?)  -- Overlaps start
                        OR (start_time >= ? AND start_time < ?) -- Starts inside
                        OR (end_time > ? AND end_time <= ?) -- Ends inside
                        OR (start_time <= ? AND end_time >= ?) -- Completely surrounds
                    )
                )
                """

            var statement: OpaquePointer? = nil

            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(tableNumber))
                sqlite3_bind_text(statement, 2, (formattedDate as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 3, (formattedStartTime as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 4, (formattedStartTime as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 5, (formattedStartTime as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 6, (formattedEndTime as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 7, (formattedStartTime as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 8, (formattedEndTime as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 9, (formattedStartTime as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 10, (formattedEndTime as NSString).utf8String, -1, nil)

                if sqlite3_step(statement) == SQLITE_ROW {
                    let exists = sqlite3_column_int(statement, 0) == 1
                    sqlite3_finalize(statement)
                    return exists
                } else {
                    print("Error checking for conflicting reservations")
                    sqlite3_finalize(statement)
                    return false
                }
            } else {
                print("Error preparing validation statement: \(String(cString: sqlite3_errmsg(db)))")
                return false
            }
        }
    

        func insertBooking(tableNumber: Int, seats: Int, reservationDate: Date, startTime: Date, endTime: Date) -> Bool {
            let username = DatabaseHelper.accessedUsername
               

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"

            let formattedDate = dateFormatter.string(from: reservationDate)
            let formattedStartTime = timeFormatter.string(from: startTime)
            let formattedEndTime = timeFormatter.string(from: endTime)

            let query = """
                INSERT INTO bookings (customer_id, table_number, seats, reservation_date, start_time, end_time)
                VALUES ((SELECT costumer_id FROM customers WHERE username = ?), ?, ?, ?, ?, ?)
                """
            var statement: OpaquePointer? = nil

            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, (username as NSString).utf8String, -1, nil)
                sqlite3_bind_int(statement, 2, Int32(tableNumber))
                sqlite3_bind_int(statement, 3, Int32(seats))
                sqlite3_bind_text(statement, 4, (formattedDate as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 5, (formattedStartTime as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 6, (formattedEndTime as NSString).utf8String, -1, nil)

                if sqlite3_step(statement) == SQLITE_DONE {
                    sqlite3_finalize(statement)
                    return true
                } else {
                    print("Error inserting booking")
                }
            } else {
                print("Error preparing booking insert")
            }
            sqlite3_finalize(statement)
            return false
        }
    
    func fetchBookings() -> [Booking] {
        let query = """
            SELECT table_number, seats, reservation_date, start_time, end_time
            FROM bookings
            WHERE customer_id = (SELECT costumer_id FROM customers WHERE username = ?)
            """
        var statement: OpaquePointer? = nil
        var bookings: [Booking] = []

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (DatabaseHelper.accessedUsername as NSString).utf8String, -1, nil)

            while sqlite3_step(statement) == SQLITE_ROW {
                let tableNumber = sqlite3_column_int(statement, 0)
                let seats = sqlite3_column_int(statement, 1)

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let reservationDate = dateFormatter.date(from: String(cString: sqlite3_column_text(statement, 2))) ?? Date()

                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm:ss"
                let startTime = timeFormatter.date(from: String(cString: sqlite3_column_text(statement, 3))) ?? Date()
                let endTime = timeFormatter.date(from: String(cString: sqlite3_column_text(statement, 4))) ?? Date()

                let booking = Booking(tableNumber: Int(tableNumber), seats: Int(seats), reservationDate: reservationDate, startTime: startTime, endTime: endTime)
                bookings.append(booking)
            }
        } else {
            print("Error preparing booking fetch statement: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
        return bookings
    }



    func hashPassword(_ password: String) -> String {
            let data = password.data(using: .utf8)!
            let hash = SHA256.hash(data: data)
            return hash.compactMap { String(format: "%02x", $0) }.joined()
        }
    
  
}
