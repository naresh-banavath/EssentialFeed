//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Naresh Banavath on 03/01/26.
//

import Foundation
public struct LocalFeedImage: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    public init(id: UUID = UUID(), description: String? = nil, location: String? = nil, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
