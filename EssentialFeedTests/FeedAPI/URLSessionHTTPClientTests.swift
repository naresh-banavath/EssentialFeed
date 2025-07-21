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
    struct UnexpectedValuesRepresentation: Error {}
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> ()) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestsWithURL() {
        
      
        let expectation = expectation(description: "wait for request")
        let url = anyURL()
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            expectation.fulfill()
        }
        makeSUT().get(from: url) { _ in }
        wait(for: [expectation], timeout: 1.0)

    }
    func test_getFromURL_failsOnRequestError() {
        
      
        
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil,  error: error)
        
       
        let expectation = expectation(description: "wait for completion")
        makeSUT().get(from: anyURL()) { result in
            
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.code, error.code)
                
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
                
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
                
    }
    
    func test_getFromURL_failsOnAllNilValues() {

    
        URLProtocolStub.stub(data: nil, response: nil,  error: nil)
        
       
        let expectation = expectation(description: "wait for completion")
        makeSUT().get(from: anyURL()) { result in
            
            switch result {
            case .failure:
              break
            default:
                XCTFail("Expected failure, got \(result) instead")
                
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
                
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    private func anyURL() -> URL {
        return URL(string: "https://example.com")!
    }
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            Self.requestObserver = observer
        }
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        override class func canInit(with request: URLRequest) -> Bool {
           return true
        }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            requestObserver?(request)
            return request
        }
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        override func stopLoading() { }
    }
}



