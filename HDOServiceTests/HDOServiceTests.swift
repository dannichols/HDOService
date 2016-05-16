//
//  HDOServiceTests.swift
//  HDOServiceTests
//
//  Created by Daniel Nichols on 5/15/16.
//  Copyright © 2016 Hey Danno. All rights reserved.
//

import XCTest
import HDOPromise
@testable import HDOService

class HDOServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    class BasicService: Service {
        var baseURL: NSURL? = nil
    }
    
    class OpenWeatherMapService: Service {
        var baseURL = NSURL(string: "http://api.openweathermap.org/data/2.5/")
        var appID: String = ""
        
        func weatherByCity(city: String) -> Promise<JSONDictionaryServiceResponse> {
            return self.GET("weather", ["q": city, "appid": self.appID])
        }
    }
    
    func testGET() {
        let expectation = expectationWithDescription("Request completed")
        let service = BasicService()
        service.GET("https://www.wikipedia.org").then { (response: StringServiceResponse) in
            response.parse().then({ (str) in
                guard let str = str else {
                    XCTFail("No response")
                    return
                }
                XCTAssert(str.characters.count > 10, "Bad response: \(str)")
            }).always({ 
                expectation.fulfill()
            })
        }.error { (error) in
            XCTFail("Error occurred when calling service: \(error)")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testGETWithQuery() {
        let expectation = expectationWithDescription("Request completed")
        let service = OpenWeatherMapService()
        service.weatherByCity("London,uk").then { (response) in
            response.parse().then({ (json) in
                guard let json = json else {
                    XCTFail("No response")
                    return
                }
                XCTAssert(json["cod"] != nil, "Response not received correctly")
            }).always({
                let expected = "\(service.baseURL!)weather?q=London,uk&appid=\(service.appID)"
                XCTAssert(response.response.URL!.absoluteString == expected, "URL is malformed: \(response.response.URL!.absoluteString) (expected \(expected))")
                expectation.fulfill()
            }).error({ (error) in
                XCTFail("Error occurred when parsing data: \(error)")
                expectation.fulfill()
            })
        }.error { (error) in
            XCTFail("Error occurred when calling service: \(error)")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
}
