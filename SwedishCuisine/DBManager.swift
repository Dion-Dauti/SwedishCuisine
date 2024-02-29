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

    func hashPassword(_ password: String) -> String {
            let data = password.data(using: .utf8)!
            let hash = SHA256.hash(data: data)
            return hash.compactMap { String(format: "%02x", $0) }.joined()
        }
    
  
}
