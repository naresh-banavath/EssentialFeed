//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Banavath, Naresh on 13/07/25.
//

import Foundation
internal final class FeedItemsWrapper {
    private struct Root: Decodable {
        let items: [Item]
        var feed: [FeedItem] {
            items.map { $0.item }
        }
    }
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }

    }
    private static var OK_200: Int { return 200 }

    internal static func map(_ data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return.failure(.invalidData)
        }
        return .success(root.feed)
    }
}
