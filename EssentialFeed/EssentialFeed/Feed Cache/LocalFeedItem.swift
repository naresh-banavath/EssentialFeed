//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Naresh Banavath on 03/01/26.
//

import Foundation
public struct LocalFeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    public init(id: UUID = UUID(), description: String? = nil, location: String? = nil, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
