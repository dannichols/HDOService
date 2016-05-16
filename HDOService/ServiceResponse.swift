//
//  RESTResponse.swift
//  SocialTVCore
//
//  Created by Daniel Nichols on 4/12/16.
//  Copyright © 2016 Hey Danno. All rights reserved.
//

import Foundation
import HDOPromise

/// Possible HTTP response codes
public enum ServiceResponseStatus: Int {
    case
    Unknown = 0,
    Continue = 100,
    SwitchingProtocols = 101,
    OK = 200,
    Created = 201,
    Accepted = 202,
    NonAuthoritativeInformation = 203,
    NoContent = 204,
    ResetContent = 205,
    PartialContent = 206,
    MultipleChoices = 300,
    MovedPermanently = 301,
    Found = 302,
    SeeOther = 303,
    NotModified = 304,
    UseProxy = 305,
    TemporaryRedirect = 307,
    BadRequest = 400,
    Unauthorized = 401,
    PaymentRequired = 402,
    Forbidden = 403,
    NotFound = 404,
    MethodNotAllowed = 405,
    NotAcceptable = 406,
    ProxyAuthenticationRequired = 407,
    RequestTimeout = 408,
    Conflict = 409,
    Gone = 410,
    LengthRequired = 411,
    PreconditionFailed = 412,
    RequestEntityTooLarge = 413,
    RequestURITooLong = 414,
    UnsupportedMediaType = 415,
    RequestedRangeNotSatisfiable = 416,
    ExpectationFailed = 417,
    InternalServerError = 500,
    NotImplemented = 501,
    BadGateway = 502,
    ServiceUnavailable = 503,
    GatewayTimeout = 504,
    HTTPVersionNotSupported = 505
    
    /// Translates an integer into a supported code
    /// - parameter code: The raw integer value
    /// - returns: The status code
    public static func withValue(code: Int) -> ServiceResponseStatus {
        guard let value = ServiceResponseStatus(rawValue: code) else {
            return .Unknown
        }
        return value
    }
    
    /// Whether or not this is an informational response code
    public var isInformational: Bool {
        get {
            return self.rawValue >= 100 && self.rawValue < 200
        }
    }
    
    /// Whether or not this is an successful response code
    public var isSuccessful: Bool {
        get {
            return self.rawValue >= 200 && self.rawValue < 300
        }
    }
    
    /// Whether or not this is an redirection response code
    public var isRedirect: Bool {
        get {
            return self.rawValue >= 300 && self.rawValue < 400
        }
    }
    
    /// Whether or not this is an client error response code
    public var isClientError: Bool {
        get {
            return self.rawValue >= 400 && self.rawValue < 500
        }
    }
    
    /// Whether or not this is an server error response code
    public var isServerError: Bool {
        get {
            return self.rawValue >= 500 && self.rawValue < 600
        }
    }

}

/// Interface for the response from a service request
public protocol ServiceResponse {
    
    /// The response received
    var response: NSHTTPURLResponse { get }
    
    /// The body of the response
    var data: NSData? { get }
    
    /// Creates a new response
    /// - parameter response: The HTTP response received
    /// - parameter data: The body of the response, if any
    init(response: NSHTTPURLResponse, data: NSData?)
    
}

public extension ServiceResponse {
    
    /// The HTTP status code of the response
    var status: ServiceResponseStatus {
        get {
            return ServiceResponseStatus.withValue(self.response.statusCode)
        }
    }
    
    /// The value of the HTTP Content-Encoding header
    var contentEncoding: String? {
        get {
            guard let value = self.response.allHeaderFields["Content-Encoding"] as? String else {
                return nil
            }
            return value
        }
    }
    
    /// The value of the HTTP Content-Type header
    var contentType: String? {
        get {
            guard let value = self.response.allHeaderFields["Content-Type"] as? String else {
                return nil
            }
            return value
        }
    }
    
    /// Whether or not the response is an error
    var isError: Bool {
        get {
            return self.status.isClientError || self.status.isServerError
        }
    }

}

/// A simple response that can be received from a service request
public class BasicServiceResponse: ServiceResponse {
    
    /// The response received
    public let response: NSHTTPURLResponse
    
    /// The body of the response
    public let data: NSData?
    
    /// Creates a new response
    /// - parameter response: The HTTP response received
    /// - parameter data: The body of the response, if any
    public required init(response: NSHTTPURLResponse, data: NSData?) {
        self.response = response
        self.data = data
    }
    
}

/// A response with a body that can be decoded. This is an abstract base
/// class, and must be subclassed to be used.
public class DecoderServiceResponse<T>: BasicServiceResponse {
    
    /// Creates a new response
    /// - parameter response: The HTTP response received
    /// - parameter data: The body of the response, if any
    public required init(response: NSHTTPURLResponse, data: NSData?) {
        super.init(response: response, data: data)
    }
    
    /// Decodes the response body
    /// - returns: A promise that resolves with the decoded data, if any
    public func parse() -> Promise<T?> {
        return Promise<T?> { (onFulfilled, onRejected) in
            guard let data = self.data else {
                onFulfilled(nil)
                return
            }
            do {
                let decoded = try self.decode(data)
                onFulfilled(decoded)
            } catch {
                onRejected(error)
            }
        }
    }
    
    /// Decodes raw data
    /// - returns: The decoded data, if any
    /// - throws: An error that occurred while parsing the data
    public func decode(data: NSData) throws -> T? {
        print("Call to abstract function: DecoderServiceResponse<T>::decode")
        fatalError()
    }
    
}

/// A response with a string body
public class StringServiceResponse: DecoderServiceResponse<String> {
    
    /// The encoding of the string data. Defaults to UTF-8
    public var encoding: UInt = NSUTF8StringEncoding
    
    /// Creates a new response
    /// - parameter response: The HTTP response received
    /// - parameter data: The body of the response, if any
    public required init(response: NSHTTPURLResponse, data: NSData?) {
        super.init(response: response, data: data)
    }
    
    /// A response with a UTF-8 string body
    public typealias UTF8 = StringServiceResponse
    
    
    /// A response with a UTF-16 string body
    public class UTF16: StringServiceResponse {
        
        /// Creates a new response
        /// - parameter response: The HTTP response received
        /// - parameter data: The body of the response, if any
        public required init(response: NSHTTPURLResponse, data: NSData?) {
            super.init(response: response, data: data)
            self.encoding = NSUTF16StringEncoding
        }

    }

    /// Decodes raw data
    /// - returns: The decoded data, if any
    /// - throws: An error that occurred while parsing the data
    public override func decode(data: NSData) throws -> String? {
        return String(data: data, encoding: self.encoding)
    }
    
}

/// A response with an image body
public class ImageServiceResponse: DecoderServiceResponse<UIImage> {
    
    /// Creates a new response
    /// - parameter response: The HTTP response received
    /// - parameter data: The body of the response, if any
    public required init(response: NSHTTPURLResponse, data: NSData?) {
        super.init(response: response, data: data)
    }
    
    /// Decodes raw data
    /// - returns: The decoded data, if any
    /// - throws: An error that occurred while parsing the data
    public override func decode(data: NSData) throws -> UIImage? {
        return UIImage(data: data)
    }
    
}

// A response with a JSON object body
public class JSONDictionaryServiceResponse: DecoderServiceResponse<JSONDictionary> {
    
    /// Creates a new response
    /// - parameter response: The HTTP response received
    /// - parameter data: The body of the response, if any
    public required init(response: NSHTTPURLResponse, data: NSData?) {
        super.init(response: response, data: data)
    }
    
    /// Decodes raw data
    /// - returns: The decoded data, if any
    /// - throws: An error that occurred while parsing the data
    public override func decode(data: NSData) throws -> JSONDictionary? {
        let deserialized = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? JSONDictionary
        return deserialized
    }
    
}

/// A response with a JSON array body
public class JSONArrayServiceResponse: DecoderServiceResponse<JSONArray> {
    
    /// Creates a new response
    /// - parameter response: The HTTP response received
    /// - parameter data: The body of the response, if any
    public required init(response: NSHTTPURLResponse, data: NSData?) {
        super.init(response: response, data: data)
    }
    
    /// Decodes raw data
    /// - returns: The decoded data, if any
    /// - throws: An error that occurred while parsing the data
    public override func decode(data: NSData) throws -> JSONArray? {
        let deserialized = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? JSONArray
        return deserialized
    }
    
}

/// A response with an XML body
public class XMLServiceResponse: DecoderServiceResponse<NSXMLParser> {
    
    /// Creates a new response
    /// - parameter response: The HTTP response received
    /// - parameter data: The body of the response, if any
    public required init(response: NSHTTPURLResponse, data: NSData?) {
        super.init(response: response, data: data)
    }
    
    /// Decodes raw data
    /// - returns: The decoded data, if any
    /// - throws: An error that occurred while parsing the data
    public override func decode(data: NSData) throws -> NSXMLParser? {
        return NSXMLParser(data: data)
    }

}