//
//  RemoteFeedLoader.swift
//  EssentialFeedTests
//
//  Created by Banavath, Naresh on 06/07/25.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)

    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://example.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url])
    }
    func test_loadtwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://example.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        var capturedErrors =  [RemoteFeedLoader.Error]()
        
        client.error = NSError(domain: "Test", code: 0)
        
        sut.load()  { capturedErrors.append($0) }
 
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    
        
    }
    
    //MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://example.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        var requestedURL: URL?
        var requestedURLs = [URL]()
        var error: Error?
        func get(from url: URL, completion: @escaping (Error?) -> Void) {
            requestedURL = url
            requestedURLs.append(url)
            if let error = error {
                completion(error)
            }
            
        }
            
    }
}
    

