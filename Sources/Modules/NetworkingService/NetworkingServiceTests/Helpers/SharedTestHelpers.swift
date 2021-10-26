//
//  SharedTestHelpers.swift
//  NetworkingServiceTests
//
//  Created by Christian Slanzi on 26.10.21.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "https://example.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}
