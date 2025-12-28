//
//  Bookmark.swift
//  Pods
//
//  Created by Ajith Tom Jacob on 28/12/25.
//

import Foundation
import RealmSwift

/// A Highlight object
open class Bookmark: Object {
    @objc open dynamic var bookId: String!
    @objc open dynamic var pageNumber: Int = 0
    @objc open dynamic var pageOffsetX: Int = 0
    @objc open dynamic var pageOffsetY: Int = 0
    @objc open dynamic var date: Date!
    @objc open dynamic var bookmarkId: String!
    @objc open dynamic var bookmarkName: String!

    override open class func primaryKey()-> String {
        return "bookmarkId"
    }
}

/// DB helpers
extension Bookmark {
    
    public struct MatchingBookmark {
        var bookId: String
        var pageNumber: Int
        var pageOffsetX: Int
        var pageOffsetY: Int
    }

    /// Save a Bookmark with completion block
    ///
    /// - Parameters:
    ///   - readerConfig: Current folio reader configuration.
    ///   - completion: Completion block.
    public func persist(withConfiguration readerConfig: FolioReaderConfig, completion: Completion? = nil) {
        do {
            let realm = try Realm(configuration: readerConfig.realmConfiguration)
            realm.beginWrite()
            realm.add(self, update: .modified)
            try realm.commitWrite()
            completion?(nil)
        } catch let error as NSError {
            print("Error on persist highlight: \(error)")
            completion?(error)
        }
    }

    /// Remove a Bookmark
    ///
    /// - Parameter readerConfig: Current folio reader configuration.
    public func remove(withConfiguration readerConfig: FolioReaderConfig) {
        do {
            guard let realm = try? Realm(configuration: readerConfig.realmConfiguration) else {
                return
            }
            try realm.write {
                realm.delete(self)
                try realm.commitWrite()
            }
        } catch let error as NSError {
            print("Error on remove highlight: \(error)")
        }
    }

    /// Remove a Bookmark by ID
    ///
    /// - Parameters:
    ///   - readerConfig: Current folio reader configuration.
    ///   - bookmarkId: The ID to be removed
    public static func removeById(withConfiguration readerConfig: FolioReaderConfig, bookmarkId: String) {
        var bookmark: Bookmark?
        let predicate = NSPredicate(format:"bookmarkId = %@", bookmarkId)

        do {
            let realm = try Realm(configuration: readerConfig.realmConfiguration)
            bookmark = realm.objects(Bookmark.self).filter(predicate).toArray(Bookmark.self).first
            bookmark?.remove(withConfiguration: readerConfig)
        } catch let error as NSError {
            print("Error on remove highlight by id: \(error)")
        }
    }
    
    /// Return a Bookmark by ID
    ///
    /// - Parameter:
    ///   - readerConfig: Current folio reader configuration.
    ///   - bookmarkId: The ID to be removed
    ///   - page: Page number
    /// - Returns: Return a Bookmark
    public static func getById(withConfiguration readerConfig: FolioReaderConfig, bookmarkId: String) -> Bookmark? {
        var bookmark: Bookmark?
        let predicate = NSPredicate(format:"bookmarkId = %@", bookmarkId)

        do {
            let realm = try Realm(configuration: readerConfig.realmConfiguration)
            bookmark = realm.objects(Bookmark.self).filter(predicate).toArray(Bookmark.self).first
            return bookmark
        } catch let error as NSError {
            print("Error getting Highlight : \(error)")
        }

        return bookmark
    }
    
    // Return a Bookmark by MatchingBookmark
    ///
    /// - Parameter:
    ///   - readerConfig: Current folio reader configuration.
    ///   - matchingBookmark: The MatchingBookmark to be removed
    /// - Returns: Return a Bookmark
    public static func getByMatchingBookmark(withConfiguration readerConfig: FolioReaderConfig, matchingBookmark: MatchingBookmark) -> Bookmark? {
        var bookmark: Bookmark?
        let predicate = NSPredicate(format:"bookId = %@ && pageNumber = %d && pageOffsetX = %d && pageOffsetY = %d", matchingBookmark.bookId, matchingBookmark.pageNumber, matchingBookmark.pageOffsetX, matchingBookmark.pageOffsetY)
        
        do {
            let realm = try Realm(configuration: readerConfig.realmConfiguration)
            bookmark = realm.objects(Bookmark.self).filter(predicate).toArray(Bookmark.self).first
            return bookmark
        } catch let error as NSError {
            print("Error getting Highlight : \(error)")
        }

        return bookmark
    }


    /// Return a list of Bookmark with a given ID
    ///
    /// - Parameters:
    ///   - readerConfig: Current folio reader configuration.
    ///   - bookId: Book ID
    ///   - page: Page number
    /// - Returns: Return a list of Highlights
    public static func allByBookId(withConfiguration readerConfig: FolioReaderConfig, bookId: String, andPage page: NSNumber? = nil) -> [Bookmark] {
        var bookmarks: [Bookmark]?
        var predicate = NSPredicate(format: "bookId = %@", bookId)
        if let page = page {
            predicate = NSPredicate(format: "bookId = %@ && page = %@", bookId, page)
        }

        do {
            let realm = try Realm(configuration: readerConfig.realmConfiguration)
            bookmarks = realm.objects(Bookmark.self).filter(predicate).sorted(byKeyPath: "date", ascending: false).toArray(Bookmark.self)
            return (bookmarks ?? [])
        } catch let error as NSError {
            print("Error on fetch all by book Id: \(error)")
            return []
        }
    }

    /// Return all Bookmarks
    ///
    /// - Parameter readerConfig: - readerConfig: Current folio reader configuration.
    /// - Returns: Return all Bookmarks
    public static func all(withConfiguration readerConfig: FolioReaderConfig) -> [Bookmark] {
        var bookmarks: [Bookmark]?
        do {
            let realm = try Realm(configuration: readerConfig.realmConfiguration)
            bookmarks = realm.objects(Bookmark.self).toArray(Bookmark.self)
            return (bookmarks ?? [])
        } catch let error as NSError {
            print("Error on fetch all: \(error)")
            return []
        }
    }
}

/// Page Helpers
extension Bookmark {

    public static func newBookmark(_ matchingBookmark: MatchingBookmark, with name: String) -> Bookmark {
        let bookmark = Bookmark()
        bookmark.bookmarkId = UUID().uuidString
        bookmark.bookId = matchingBookmark.bookId
        bookmark.pageNumber = matchingBookmark.pageNumber
        bookmark.pageOffsetX = matchingBookmark.pageOffsetX
        bookmark.pageOffsetY = matchingBookmark.pageOffsetY
        bookmark.date = Date()
        bookmark.bookmarkName = name
        return bookmark
    }
}
