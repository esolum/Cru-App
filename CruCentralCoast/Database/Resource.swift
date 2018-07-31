//
//  Resource.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/23/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import Foundation

enum ResourceType {
    case audio
    case video
    case article
}

extension ResourceType {
    var string: String {
        switch self {
        case .audio:
            return "audio"
        case .video:
            return "video"
        case .article:
            return "article"
        }
    }
}

class Resource: DatabaseObject {
    var author: String
    var title: String
    var date: Date
    var url: String
    var type: ResourceType
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self.date)
    }
    
    required init?(dict: NSDictionary) {
        guard let author = dict["author"] as? String,
        let title = dict["title"] as? String,
        let date = dict["date"] as? Date,
        let url = dict["url"] as? String,
        let type = dict["type"] as? String else {
            return nil
        }
        self.author = author
        self.title = title
        self.date = date
        self.url = url
        switch type {
        case "audio":
            self.type = .audio
        case "video":
            self.type = .video
        default: //case "article":
            self.type = .article
        }
    }
    
    static func createResource(dict: NSDictionary) -> Resource? {
        guard let type = dict["type"] as? String else {
            return nil
        }
        switch type {
        case "audio":
            return AudioResource(dict: dict)
        case "video":
            return VideoResource(dict: dict)
        default: //case "article":
            return ArticleResource(dict: dict)
        }
    }
}
