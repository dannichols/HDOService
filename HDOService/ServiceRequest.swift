//
//  ServiceRequest.swift
//  SocialTVCore
//
//  Created by Daniel Nichols on 4/16/16.
//  Copyright © 2016 Hey Danno. All rights reserved.
//

import Foundation

/// A header dictionary
public typealias ServiceRequestHeaders = [String: String]

/// A query string parameter dictionary
public typealias ServiceRequestQuery = [String: AnyObject]

/// Supported HTTP verbs
public enum ServiceRequestMethod: String {
    case
    /// The GET verb
    GET = "GET",
    /// The POST verb
    POST = "POST",
    /// The PUT verb
    PUT = "PUT",
    /// The PATCH verb
    PATCH = "PATCH",
    /// The DELETE verb
    DELETE = "DELETE",
    /// The OPTIONS verb
    OPTIONS = "OPTIONS",
    /// The HEAD verb
    HEAD = "HEAD",
    /// The TRACE verb
    TRACE = "TRACE",
    /// The CONNECT verb
    CONNECT = "CONNECT"
    
    /// Whether or not this verb supports a body
    var allowsBody: Bool {
        get {
            switch (self) {
            case .GET:
                fallthrough
            case .DELETE:
                fallthrough
            case .OPTIONS:
                fallthrough
            case .HEAD:
                fallthrough
            case .TRACE:
                fallthrough
            case .CONNECT:
                return false
            default:
                return true
            }
        }
    }
}

/// Interface for a request that can be passed to a service
public protocol ServiceRequest {

    /// The HTTP verb to use for the request
    var method: ServiceRequestMethod { get }
    
    /// The URL to which to send the request
    var url: NSURL { get }
    
    /// HTTP headers to send with the request
    var headers: ServiceRequestHeaders? { get }
    
    /// Query string parameters to append to the request URL
    var query: ServiceRequestQuery? { get }
    
    /// The HTTP body to send with the request
    var body: ServiceRequestBody? { get }

}

/// A simple request that can be passed to a service
public class BasicServiceRequest: ServiceRequest {
    
    /// The HTTP verb to use for the request
    public private(set) var method: ServiceRequestMethod
    
    /// The URL to which to send the request
    public private(set) var url: NSURL
    
    /// HTTP headers to send with the request
    public private(set) var headers: ServiceRequestHeaders?
    
    /// Query string parameters to append to the request URL
    public private(set) var query: ServiceRequestQuery?
    
    /// The HTTP body to send with the request
    public private(set) var body: ServiceRequestBody?
    
    /// Creates a new request
    /// - parameter method: The HTTP verb to use
    /// - parameter url: The URL to which to send the request
    /// - parameter headers: Optional HTTP headers to pass
    /// - parameter query: Optional query string parameters to append to the URL
    /// - parameter body: Optional HTTP body to send with the request
    public init(method: ServiceRequestMethod, url: NSURL, headers: ServiceRequestHeaders?, query: ServiceRequestQuery?, body: ServiceRequestBody?) {
        self.method = method
        self.url = url
        self.headers = headers
        self.query = query
        self.body = body
    }
    
    /// Creates a new request
    /// - parameter method: The HTTP verb to use
    /// - parameter url: The URL to which to send the request
    public convenience init(method: ServiceRequestMethod, url: NSURL) {
        self.init(method: method, url: url, headers: nil, query: nil, body: nil)
    }

}

/// Interface for a body to pass with a request
public protocol ServiceRequestBody {
    
    /// The data to send as the body
    var data: NSData? { get }
    
}

/// A request body passing raw data
public class DataServiceRequestBody: ServiceRequestBody {
    
    /// The data to send as the body
    public let data: NSData?
    
    /// Creates a new body
    /// - parameter value: The data to send as the body
    public init(_ value: NSData?) {
        self.data = value
    }
    
}

/// A request body passing a string
public class StringServiceRequestBody: DataServiceRequestBody {
    
    /// Creates a new body
    /// - parameter value: The string to send as the body
    /// - parameter encoding: The byte encoding to use
    public init(_ value: String?, encoding: UInt) {
        super.init(value?.dataUsingEncoding(encoding))
    }
    
    /// Creates a new body with UTF-8 encoding
    /// - parameter value: The string to send as the body
    public convenience init(_ value: String?) {
        self.init(value, encoding: NSUTF8StringEncoding)
    }
    
}

/// A request body passing named values, as in a web form
public class FormServiceRequestBody: StringServiceRequestBody {
    
    /// Creates a new body
    /// - parameter params: The parameters to send
    /// - parameter encoding: The byte encoding to use
    public init(_ params: ServiceRequestQuery, encoding: UInt) {
        let query = NSURLComponents.encodeQueryString(params)
        super.init(query, encoding: encoding)
    }
    
    /// Creates a new body with UTF-8 encoding
    /// - parameter params: The parameters to send
    public convenience init(_ params: ServiceRequestQuery) {
        self.init(params, encoding: NSUTF8StringEncoding)
    }
    
}

/// A request body passing a JSON object
public class JSONDictionaryServiceRequestBody: DataServiceRequestBody {
    
    /// Creates a new body
    /// - parameter value: The JSON object
    /// - parameter encoding: The byte encoding to use
    public init(_ value: JSONDictionary, encoding: UInt) {
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(value, options: NSJSONWritingOptions())
            super.init(data)
        } catch {
            super.init(nil)
        }
    }
    
    /// Creates a new body with UTF-8 encoding
    /// - parameter value: The JSON object
    public convenience init(_ params: JSONDictionary) {
        self.init(params, encoding: NSUTF8StringEncoding)
    }
    
}

/// A request body passing a JSON array
public class JSONArrayServiceRequestBody: DataServiceRequestBody {
    
    /// Creates a new body
    /// - parameter value: The JSON array
    /// - parameter encoding: The byte encoding to use
    public init(_ value: JSONArray, encoding: UInt) {
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(value, options: NSJSONWritingOptions())
            super.init(data)
        } catch {
            super.init(nil)
        }
    }
    
    /// Creates a new body with UTF-8 encoding
    /// - parameter value: The JSON array
    public convenience init(_ array: JSONArray) {
        self.init(array, encoding: NSUTF8StringEncoding)
    }
    
}