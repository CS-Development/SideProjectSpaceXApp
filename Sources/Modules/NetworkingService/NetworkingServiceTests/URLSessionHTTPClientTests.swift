//
//  URLSessionHTTPClientTests.swift
//  NetworkingServiceTests
//
//  Created by Christian Slanzi on 26.10.21.
//

import XCTest
import NetworkingService

/// We test the functionalities of the URLSessionHTTPClient in Isolation, that means we want also to test the client independently from the Network
/// Aka without to make any real network request. To achieve this purpose we are going to stub the URLProtocol. Stubbing means that the stub object will answer with the hardcoded data we'll provide to it, either successful data or failure errors, and we will verifiy that the SUT (system under test) reacts in the desired way, spying/intercepting the methods of the URLProtocol.

class URLSessionHTTPClientTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        URLProtocolStub.startInterceptingRequests()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        URLProtocolStub.stopInterceptingRequests()
    }
    
    
    
    // MARK: - Helpers
    
    private func resultErrorFor(data: Data?,
                                response: URLResponse?,
                                error: Error?, file: StaticString = #filePath,
                                line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        guard let error = result.error else {
            XCTFail("expected failure, got \(result) instead")
            return nil
        }

        return error
    }

    private func resultValueFor(data: Data?,
                                response: URLResponse?,
                                error: Error?, file: StaticString = #filePath,
                                line: UInt = #line) -> (data: Data, response: HTTPClientResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        guard let receivedData = result.data, let receivedResponse = result.response else {
            XCTFail("expected success, got \(result) instead")
            return nil
        }

        return (receivedData, receivedResponse)
    }
    
    private func resultFor(data: Data?,
                           response: URLResponse?,
                           error: Error?, file: StaticString = #filePath,
                           line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let url = anyURL()
        let sut = makeSUT(file: file, line: line)
        var receivedResult: HTTPClientResult!
        let exp = expectation(description: "wait for completion")
        
        sut.makeRequest(toURL: url, withHttpMethod: .get) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func anyData() -> Data {
        return Data("any data".utf8)
    }

    private func anyNonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private class URLProtocolStub: URLProtocol {
        
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        // the HTTPResult Stub
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        // MARK: override URLProtocol's methods

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
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
        
        override func stopLoading() {}
        
        // MARK: static helper methods for the stubbing/intercepting

        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }

        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
        }
    }
}
