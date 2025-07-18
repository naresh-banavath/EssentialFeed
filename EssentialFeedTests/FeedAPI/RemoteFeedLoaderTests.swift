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
        sut.load() { _ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }
    func test_loadtwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://example.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load() { _ in }
        sut.load() { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199,201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }

    }
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([])) {
            let emptyJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyJSON)
        }
    }
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        let item1  = makeItem(
            id: UUID(),
            imageURL: URL(string: "https://example.com/image1")!
        )
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "https://example.com/image2")!
        )
        
    
        let items = [item1.model, item2.model]
        expect(sut, toCompleteWith: .success(items)) {
             let json = self.makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        }
        

    }
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://example.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
      
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load() { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
        
    //MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://example.com")!,file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut,file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
        
    }
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString, line: UInt) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String:Any]) {
        
        let item = FeedItem(
            id: id,
            description: description,
            location: location,
            imageURL: imageURL
        )
        let json: [String: Any] = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageURL.absoluteString
        ].compactMapValues({ $0 })
        return (item, json)
    }
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {

        let expectations = expectation(description: "Wait for load completion")
        sut.load() { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            expectations.fulfill()
            
        }
        action()
        wait(for: [expectations], timeout: 1.0)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            
            messages.append((url: url, completion: completion))
        }
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )
            messages[index].completion(.success(data,response!))
            
        }
            
    }
}
    

