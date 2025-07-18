//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Banavath, Naresh on 15/07/25.
//


import XCTest
import EssentialFeed

class URLSessionHTTPClient {

    let session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> ()) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "https://example.com")!
        
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(url: url, data: nil, response: nil,  error: error)
        
        let sut = URLSessionHTTPClient()
        let expectation = expectation(description: "wait for completion")
        sut.get(from: url) { result in
            
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.code, error.code)
                
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
                
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequests()
        
    }
    
    // MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
            stubs[url] = Stub(data: data, response: response, error: error)
        }
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs.removeAll()
        }
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return URLProtocolStub.stubs[url] != nil
        }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        override func startLoading() {
            guard let url = request.url, let stub = Self.stubs[url] else { return }
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        override func stopLoading() { }
    }
}



