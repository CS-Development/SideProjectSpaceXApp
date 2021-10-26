//
//  URLSessionHTTPClientTests.swift
//  NetworkingServiceTests
//
//  Created by Christian Slanzi on 26.10.21.
//

import XCTest

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

    private class URLProtocolStub: URLProtocol {
        
        static func startInterceptingRequests() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
        }
    }
}
