//
//  Service.swift
//  SocialTVCore
//
//  Created by Daniel Nichols on 3/30/16.
//  Copyright © 2016 Hey Danno. All rights reserved.
//

import Foundation
import HDOPromise

/// A basic JSON dictionary data type
public typealias JSONDictionary = [String: AnyObject]

/// A basic JSON array data type
public typealias JSONArray = [AnyObject]

/// An object used for accessing a RESTful web service. Each web service used by a project should
/// be defined as a Service helper class.
public protocol Service {
    
    /// An optional URL to use as the basis of all requests made via this service
    var baseURL: NSURL? { get }

}

public extension Service {
    
    /// Factory function used to transform request options into a request object
    /// - parameter method: The HTTP verb used to make the request
    /// - parameter url: The URL used to make the request
    /// - parameter headers: The HTTP headers to attach to the request
    /// - parameter query: Query string parameters to append to the URL
    /// - parameter body: The HTTP body of the request
    /// - returns: The service request
    public func buildRequest(method: ServiceRequestMethod, url: NSURL, headers: ServiceRequestHeaders?, query: ServiceRequestQuery?, body: ServiceRequestBody?) -> ServiceRequest {
        return BasicServiceRequest(method: method, url: url, headers: headers, query: query, body: body)
    }
    
    /// Make a web request
    /// - parameter method: The HTTP verb used to make the request
    /// - parameter url: The URL used to make the request
    /// - returns: A promise that's resolved with the response
    public func send<T: ServiceResponse>(method: ServiceRequestMethod, url: NSURL) -> Promise<T> {
        return self.send(method, url: url, headers: nil, query: nil, body: nil)
    }
    
    /// Make a web request
    /// - parameter method: The HTTP verb used to make the request
    /// - parameter url: The URL used to make the request
    /// - returns: A promise that's resolved with the response
    public func send<T: ServiceResponse>(method: ServiceRequestMethod, url: String) -> Promise<T> {
        return self.send(method, url: url, headers: nil, query: nil, body: nil)
    }
    
    /// Make a web request
    /// - parameter method: The HTTP verb used to make the request
    /// - parameter url: The URL used to make the request
    /// - parameter headers: The HTTP headers to attach to the request
    /// - parameter query: Query string parameters to append to the URL
    /// - parameter body: The HTTP body of the request
    /// - returns: A promise that's resolved with the response
    public func send<T: ServiceResponse>(method: ServiceRequestMethod, url: NSURL, headers: ServiceRequestHeaders?, query: ServiceRequestQuery?, body: ServiceRequestBody?) -> Promise<T> {
        let request = self.buildRequest(method, url: url, headers: headers, query: query, body: body)
        return self.send(request)
    }
    
    /// Make a web request
    /// - parameter method: The HTTP verb used to make the request
    /// - parameter url: The URL used to make the request
    /// - parameter headers: The HTTP headers to attach to the request
    /// - parameter query: Query string parameters to append to the URL
    /// - parameter body: The HTTP body of the request
    /// - returns: A promise that's resolved with the response
    public func send<T: ServiceResponse>(method: ServiceRequestMethod, url: String, headers: ServiceRequestHeaders?, query: ServiceRequestQuery?, body: ServiceRequestBody?) -> Promise<T> {
        var absoluteURL: NSURL?
        if let baseURL = self.baseURL {
            absoluteURL = NSURL(string: url, relativeToURL: baseURL)?.absoluteURL
        } else {
            absoluteURL = NSURL(string: url)
        }
        guard let url = absoluteURL else {
            return Promise<T>.reject(NSError(domain: "com.heydanno.Service", code: 400, userInfo: ["reason": "Invalid URL"]))
        }
        return self.send(method, url: url, headers: headers, query: query, body: body)
    }
    
    /// Make a web request
    /// - parameter request: The full request data to send
    /// - returns: A promise that's resolved with the response
    public func send<T: ServiceResponse>(request: ServiceRequest) -> Promise<T> {
        return self.send(NSMutableURLRequest(request))
    }
    
    /// Make a web request
    /// - parameter request: The full request data to send
    /// - returns: A promise that's resolved with the response
    public func send<T: ServiceResponse>(request: NSURLRequest) -> Promise<T> {
        return Promise<T> { (onFulfilled, onRejected) in
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                if let error = error {
                    onRejected(error)
                } else {
                    guard let response = response as? NSHTTPURLResponse else {
                        onRejected(NSError(domain: "com.heydanno.Service", code: 404, userInfo: ["reason": "No response"]))
                        return
                    }
                    let result = T(response: response, data: data)
                    onFulfilled(result)
                }
            }).resume()
        }
    }
    
    /// Make a GET request
    /// - parameter url: The URL to which to send the request
    /// - returns: A promise that's resolved with the response
    public func GET<T: ServiceResponse>(url: NSURL) -> Promise<T> {
        return self.GET(url, nil)
    }
    
    /// Make a GET request
    /// - parameter url: The URL to which to send the request
    /// - returns: A promise that's resolved with the response
    public func GET<T: ServiceResponse>(url: String) -> Promise<T> {
        return self.GET(url, nil)
    }
    
    /// Make a GET request
    /// - parameter url: The URL to which to send the request
    /// - parameter query: Query string parameters to append to the URL
    /// - returns: A promise that's resolved with the response
    public func GET<T: ServiceResponse>(url: NSURL, _ query: ServiceRequestQuery?) -> Promise<T> {
        return self.send(.GET, url: url, headers: nil, query: query, body: nil)
    }
    
    /// Make a GET request
    /// - parameter url: The URL to which to send the request
    /// - parameter query: Query string parameters to append to the URL
    /// - returns: A promise that's resolved with the response
    public func GET<T: ServiceResponse>(url: String, _ query: ServiceRequestQuery?) -> Promise<T> {
        return self.send(.GET, url: url, headers: nil, query: query, body: nil)
    }
    
    /// Make a DELETE request
    /// - parameter url: The URL to which to send the request
    /// - returns: A promise that's resolved with the response
    public func DELETE<T: ServiceResponse>(url: NSURL) -> Promise<T> {
        return self.DELETE(url, nil)
    }
    
    /// Make a DELETE request
    /// - parameter url: The URL to which to send the request
    /// - returns: A promise that's resolved with the response
    public func DELETE<T: ServiceResponse>(url: String) -> Promise<T> {
        return self.DELETE(url, nil)
    }
    
    /// Make a DELETE request
    /// - parameter url: The URL to which to send the request
    /// - parameter query: Query string parameters to append to the URL
    /// - returns: A promise that's resolved with the response
    public func DELETE<T: ServiceResponse>(url: NSURL, _ query: ServiceRequestQuery?) -> Promise<T> {
        return self.send(.DELETE, url: url, headers: nil, query: query, body: nil)
    }
    
    /// Make a DELETE request
    /// - parameter url: The URL to which to send the request
    /// - parameter query: Query string parameters to append to the URL
    /// - returns: A promise that's resolved with the response
    public func DELETE<T: ServiceResponse>(url: String, _ query: ServiceRequestQuery?) -> Promise<T> {
        return self.send(.DELETE, url: url, headers: nil, query: query, body: nil)
    }
    
    /// Make an OPTIONS request
    /// - parameter url: The URL to which to send the request
    /// - returns: A promise that's resolved with the response
    public func OPTIONS<T: ServiceResponse>(url: NSURL) -> Promise<T> {
        return self.OPTIONS(url, nil)
    }
    
    /// Make an OPTIONS request
    /// - parameter url: The URL to which to send the request
    /// - returns: A promise that's resolved with the response
    public func OPTIONS<T: ServiceResponse>(url: String) -> Promise<T> {
        return self.OPTIONS(url, nil)
    }
    
    /// Make an OPTIONS request
    /// - parameter url: The URL to which to send the request
    /// - parameter query: Query string parameters to append to the URL
    /// - returns: A promise that's resolved with the response
    public func OPTIONS<T: ServiceResponse>(url: NSURL, _ query: ServiceRequestQuery?) -> Promise<T> {
        return self.send(.OPTIONS, url: url, headers: nil, query: query, body: nil)
    }
    
    /// Make an OPTIONS request
    /// - parameter url: The URL to which to send the request
    /// - parameter query: Query string parameters to append to the URL
    /// - returns: A promise that's resolved with the response
    public func OPTIONS<T: ServiceResponse>(url: String, _ query: ServiceRequestQuery?) -> Promise<T> {
        return self.send(.OPTIONS, url: url, headers: nil, query: query, body: nil)
    }
    
    /// Make a HEAD request
    /// - parameter url: The URL to which to send the request
    /// - returns: A promise that's resolved with the response
    public func HEAD<T: ServiceResponse>(url: NSURL) -> Promise<T> {
        return self.HEAD(url, nil)
    }
    
    /// Make a HEAD request
    /// - parameter url: The URL to which to send the request
    /// - returns: A promise that's resolved with the response
    public func HEAD<T: ServiceResponse>(url: String) -> Promise<T> {
        return self.HEAD(url, nil)
    }
    
    /// Make a HEAD request
    /// - parameter url: The URL to which to send the request
    /// - parameter query: Query string parameters to append to the URL
    /// - returns: A promise that's resolved with the response
    public func HEAD<T: ServiceResponse>(url: NSURL, _ query: ServiceRequestQuery?) -> Promise<T> {
        return self.send(.HEAD, url: url, headers: nil, query: query, body: nil)
    }
    
    /// Make a HEAD request
    /// - parameter url: The URL to which to send the request
    /// - parameter query: Query string parameters to append to the URL
    /// - returns: A promise that's resolved with the response
    public func HEAD<T: ServiceResponse>(url: String, _ query: ServiceRequestQuery?) -> Promise<T> {
        return self.send(.HEAD, url: url, headers: nil, query: query, body: nil)
    }
    
    /// Make a TRACE request
    /// - parameter url: The URL to which to send the request
    /// - returns: A promise that's resolved with the response
    public func TRACE<T: ServiceResponse>(url: NSURL) -> Promise<T> {
        return self.TRACE(url, nil)
    }
    
    /// Make a TRACE request
    /// - parameter url: The URL to which to send the request
    /// - returns: A promise that's resolved with the response
    public func TRACE<T: ServiceResponse>(url: String) -> Promise<T> {
        return self.TRACE(url, nil)
    }
    
    /// Make a TRACE request
    /// - parameter url: The URL to which to send the request
    /// - parameter query: Query string parameters to append to the URL
    /// - returns: A promise that's resolved with the response
    public func TRACE<T: ServiceResponse>(url: NSURL, _ query: ServiceRequestQuery?) -> Promise<T> {
        return self.send(.TRACE, url: url, headers: nil, query: query, body: nil)
    }
    
    /// Make a TRACE request
    /// - parameter url: The URL to which to send the request
    /// - parameter query: Query string parameters to append to the URL
    /// - returns: A promise that's resolved with the response
    public func TRACE<T: ServiceResponse>(url: String, _ query: ServiceRequestQuery?) -> Promise<T> {
        return self.send(.TRACE, url: url, headers: nil, query: query, body: nil)
    }
    
    /// Make a CONNECT request
    /// - parameter url: The URL to which to send the request
    /// - returns: A promise that's resolved with the response
    public func CONNECT<T: ServiceResponse>(url: NSURL) -> Promise<T> {
        return self.CONNECT(url, nil)
    }
    
    /// Make a CONNECT request
    /// - parameter url: The URL to which to send the request
    /// - returns: A promise that's resolved with the response
    public func CONNECT<T: ServiceResponse>(url: String) -> Promise<T> {
        return self.CONNECT(url, nil)
    }
    
    /// Make a CONNECT request
    /// - parameter url: The URL to which to send the request
    /// - parameter query: Query string parameters to append to the URL
    /// - returns: A promise that's resolved with the response
    public func CONNECT<T: ServiceResponse>(url: NSURL, _ query: ServiceRequestQuery?) -> Promise<T> {
        return self.send(.CONNECT, url: url, headers: nil, query: query, body: nil)
    }
    
    /// Make a CONNECT request
    /// - parameter url: The URL to which to send the request
    /// - parameter query: Query string parameters to append to the URL
    /// - returns: A promise that's resolved with the response
    public func CONNECT<T: ServiceResponse>(url: String, _ query: ServiceRequestQuery?) -> Promise<T> {
        return self.send(.CONNECT, url: url, headers: nil, query: query, body: nil)
    }
    
    /// Make a POST request
    /// - parameter url: The URL to which to send the request
    /// - parameter body: The HTTP body of the request
    /// - returns: A promise that's resolved with the response
    public func POST<T: ServiceResponse>(url: NSURL, body: ServiceRequestBody?) -> Promise<T> {
        return self.send(.POST, url: url, headers: nil, query: nil, body: body)
    }
    
    /// Make a POST request
    /// - parameter url: The URL to which to send the request
    /// - parameter body: The HTTP body of the request
    /// - returns: A promise that's resolved with the response
    public func POST<T: ServiceResponse>(url: String, body: ServiceRequestBody?) -> Promise<T> {
        return self.send(.POST, url: url, headers: nil, query: nil, body: body)
    }
    
    /// Make a PUT request
    /// - parameter url: The URL to which to send the request
    /// - parameter body: The HTTP body of the request
    /// - returns: A promise that's resolved with the response
    public func PUT<T: ServiceResponse>(url: NSURL, body: ServiceRequestBody?) -> Promise<T> {
        return self.send(.PUT, url: url, headers: nil, query: nil, body: body)
    }
    
    /// Make a PUT request
    /// - parameter url: The URL to which to send the request
    /// - parameter body: The HTTP body of the request
    /// - returns: A promise that's resolved with the response
    public func PUT<T: ServiceResponse>(url: String, body: ServiceRequestBody?) -> Promise<T> {
        return self.send(.PUT, url: url, headers: nil, query: nil, body: body)
    }
    
    /// Make a PATCH request
    /// - parameter url: The URL to which to send the request
    /// - parameter body: The HTTP body of the request
    /// - returns: A promise that's resolved with the response
    public func PATCH<T: ServiceResponse>(url: NSURL, body: ServiceRequestBody?) -> Promise<T> {
        return self.send(.PATCH, url: url, headers: nil, query: nil, body: body)
    }
    
    /// Make a PATCH request
    /// - parameter url: The URL to which to send the request
    /// - parameter body: The HTTP body of the request
    /// - returns: A promise that's resolved with the response
    public func PATCH<T: ServiceResponse>(url: String, body: ServiceRequestBody?) -> Promise<T> {
        return self.send(.PATCH, url: url, headers: nil, query: nil, body: body)
    }
    
}