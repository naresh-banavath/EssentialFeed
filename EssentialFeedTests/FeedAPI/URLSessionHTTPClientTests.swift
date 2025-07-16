//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Banavath, Naresh on 15/07/25.
//


import XCTest

class URLSessionHTTPClient {

    let session: URLSession
    init(session: URLSession) {
        self.session = session
    }
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    
    func test_getFromURL_createsDataTaksWithURL() {
        let url = URL(string: "https://example.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        
        XCTAssertEqual(session.requestedURLs, [url])
    }
    
    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        var requestedURLs = [URL]()
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            requestedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask{}
}



