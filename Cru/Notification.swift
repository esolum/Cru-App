//
//  Notification.swift
//  Cru
//
//  Created by Erica Solum on 7/18/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class Notification: NSObject, NSCoding {
    var title: String
    var content: String
    var dateReceived: Date
    
    init?(title: String?, content: String?, dateReceived: Date) {
        guard let title = title, let content = content else { return nil }
        
        self.title = title
        self.content = content
        self.dateReceived = dateReceived
        
        super.init()
        
        if title.isEmpty || content.isEmpty {
            return nil
        }
    }
    
    convenience init?(_ dict: [String: AnyObject]?) {
        guard let dict = dict else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let message = dict["message"] as? String, let time = dict["time"] as? String, let date = dateFormatter.date(from: time) {
            self.init(title: message, content: message, dateReceived: date)
        } else {
            return nil
        }
    }
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("notifications")
    
    // Mark: Types
    struct PropertyKey {
        static let titleKey = "title"
        static let contentKey = "content"
        static let dateKey = "date"
    }
    
    // Mark: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: PropertyKey.titleKey)
        aCoder.encode(content, forKey: PropertyKey.contentKey)
        aCoder.encode(dateReceived, forKey: PropertyKey.dateKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let title = aDecoder.decodeObject(forKey: PropertyKey.titleKey) as! String
        let content = aDecoder.decodeObject(forKey: PropertyKey.contentKey) as! String
        let dateReceived = aDecoder.decodeObject(forKey: PropertyKey.dateKey) as! Date
        
        self.init(title: title, content: content, dateReceived: dateReceived)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Notification else {
            return false
        }
        
        return self.title == other.title && self.content == other.content
    }
}
