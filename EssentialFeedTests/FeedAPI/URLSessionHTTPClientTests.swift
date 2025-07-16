//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Banavath, Naresh on 15/07/25.
//


import XCTest
import EssentialFeed
protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> HTTPDataTask
}
protocol HTTPDataTask {
    func resume()
}
class URLSessionHTTPClient {

    let session: HTTPSession
    init(session: HTTPSession) {
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
    

    func test_getFromURL_resumeDataTaksWithURL() {
        let url = URL(string: "https://example.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://example.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        let error = NSError(domain: "any error", code: 1)
        session.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient(session: session)
        let expectation = expectation(description: "wait for completion")
        sut.get(from: url) { result in
            
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
                
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
                
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    // MARK: - Helpers
    
    private class HTTPSessionSpy: HTTPSession {
        private var stubs = [URL: Stub]()
        private struct Stub {
            let task: HTTPDataTask
            let error: Error?
        }
        func stub(url: URL, task: HTTPDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> HTTPDataTask {
            guard let stub = stubs[url] else {
                fatalError("No stub found for URL \(url)")
            }
            completionHandler(nil,nil,stub.error)
            return stub.task
        }
    }
    
    private class FakeURLSessionDataTask: HTTPDataTask{
        func resume() {}
    }
    private class URLSessionDataTaskSpy: HTTPDataTask{
        var resumeCallCount = 0
        func resume() {
            resumeCallCount += 1
        }
    }
}



