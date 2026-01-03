//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Naresh Banavath on 03/01/26.
//

import Foundation
internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL

}

