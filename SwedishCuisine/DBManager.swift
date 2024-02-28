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

    func hashPassword(_ password: String) -> String {
            let data = password.data(using: .utf8)!
            let hash = SHA256.hash(data: data)
            return hash.compactMap { String(format: "%02x", $0) }.joined()
        }

  
}
