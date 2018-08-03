//
//  Resource.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/23/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation
import RealmSwift

class Resource: RealmObject {
    
    // Properties
    @objc dynamic var id: String!
    @objc dynamic var title: String!
    @objc dynamic var author: String!
    @objc dynamic var date: Date!
    @objc dynamic var url: String!
    @objc dynamic private var typeString: String!
    
    // Computed Properties
    var type: ResourceType { return ResourceType(rawValue: self.typeString) ?? .article }
    var formattedDate: String { return self.date.toString(dateStyle: .medium, timeStyle: .none) }
    
    func set(with dict: [String: Any]) -> Bool {
        guard let id = dict["id"] as? String,
            let title = dict["title"] as? String,
            let author = dict["author"] as? String,
            let date = dict["date"] as? Date,
            let url = dict["url"] as? String,
            let typeString = dict["type"] as? String
        else {
            assertionFailure("Client and Server data models don't agree: \(self.className())")
            return false
        }
        
        self.id = id
        self.title = title
        self.author = author
        self.date = date
        self.url = url
        self.typeString = typeString
        return true
    }
    
    static func createResource(dict: NSDictionary) -> Resource? {
        guard let type = dict["type"] as? String else { return nil }
        
        let resource: Resource
        switch type {
        case "audio": resource = AudioResource()
        case "video": resource = VideoResource()
        default: resource = ArticleResource()
        }
        // If it fails to set the object's properties, return nil
        return resource.set(with: dict as! [String: Any]) ? resource : nil
    }
}

enum ResourceType: String {
    case audio = "audio"
    case video = "video"
    case article = "article"
}
