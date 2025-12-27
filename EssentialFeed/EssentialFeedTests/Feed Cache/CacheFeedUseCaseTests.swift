//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Naresh Banavath on 27/12/25.
//

import XCTest


class FeedStore {
    var deleteCachedFeedCallCount: Int = 0
    
}

class LocalFeedLoader {
   
    
    init(store: FeedStore) {
      
    }
}
class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
}
