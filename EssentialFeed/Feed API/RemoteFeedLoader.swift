//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Banavath, Naresh on 06/07/25.
//

import Foundation

public final class RemoteFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    public init(url: URL,client: HTTPClient) {
        self.client = client
        self.url = url
    }
        
    public func load(completion: @escaping(Result) -> Void) {
        client.get(from: url) { result in
            
            switch result {
            case let .success(data, response):
                completion(FeedItemsWrapper.map(data, response: response))
            case .failure:
                completion(.failure(.connectivity))
            }
            
        }
    }

        
}


