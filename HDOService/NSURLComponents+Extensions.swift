//
//  NSURLComponent+Extensions.swift
//  SocialTVCore
//
//  Created by Daniel Nichols on 4/13/16.
//  Copyright © 2016 Hey Danno. All rights reserved.
//

import Foundation

public extension NSURLComponents {
    
    /// Transforms a dictionary into a query string suitable for inclusion in a URL
    /// - parameter params: The parameters to encode
    /// - returns: The encoded query string, if any
    public class func encodeQueryString(params: ServiceRequestQuery) -> String? {
        let components = NSURLComponents()
        components.queryItems = []
        for (name, rawValue) in params {
            components.appendQueryStringValue(rawValue, withName: name)
        }
        return components.query
    }

    
    /// Adds a query string parameter to a URL
    /// - parameter rawValue: The value component of the query string parameter
    /// - parameter name: The name component of the query string parameter
    public func appendQueryStringValue(rawValue: AnyObject?, withName name: String) {
        if let array = rawValue as? [AnyObject?] {
            for raw in array {
                self.appendQueryStringValue(raw, withName: name)
            }
        } else {
            let value = NSURLComponents.encodeQueryStringValue(rawValue)
            let item = NSURLQueryItem(name: name, value: value)
            if self.queryItems == nil {
                self.queryItems = []
            }
            self.queryItems?.append(item)
        }
    }
    
    // Private
    
    private class func encodeQueryStringValue(value: AnyObject?) -> String {
        if let raw = value as? JSONDictionary {
            do {
                let json = try NSJSONSerialization.dataWithJSONObject(raw, options: NSJSONWritingOptions(rawValue: 0))
                if let s = String(data: json, encoding: NSUTF8StringEncoding) {
                    return s
                } else {
                    return ""
                }
            } catch {
                return ""
            }
        } else {
            return value == nil || value is NSNull ? "" : "\(value!)"
        }
    }

}