import Foundation
import SQLite3

class DataManager {
    fileprivate var db: OpaquePointer?
    fileprivate var stmt: OpaquePointer?
    fileprivate let databaseFileName = "Caliper.sqlite"
    fileprivate let tableName = "Measurements"
    
    static let shared = DataManager()
    
    func createTableIfNotExists() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(databaseFileName)
        
        print("FILEURL...\(fileURL)")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS \(tableName) (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, valueIncm TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    func insert(name: String, valueIncm: String) {
        let queryString = "INSERT INTO \(tableName) (name, valueIncm) VALUES (?,?)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 1, name, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 2, valueIncm, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding valueIncm: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
    }
    
    func getData() -> [Measurement]? {
        let queryString = "SELECT * FROM \(tableName)"
    
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error doing select: \(errmsg)")
            return nil
        }
        
        var measurements = [Measurement]()
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let valueIncm = String(cString: sqlite3_column_text(stmt, 2))
            print("\(id)-----\(name)----\(valueIncm)")
            measurements.append(Measurement(id: Int(id), name: name, valueIncm: valueIncm))
        }
        return measurements
    }
    
    func delete(name: String) {
        let queryString = "Delete from \(tableName) where name=\(name)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error while deleting: \(errmsg)")
            return
        }
        
        if (sqlite3_step(stmt) == SQLITE_DONE) {
            print("Successfully deleted")
        }
    }
}
