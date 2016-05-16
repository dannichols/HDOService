//
//  NSMutableURLRequest+Extensions.swift
//  SocialTVCore
//
//  Created by Daniel Nichols on 5/10/16.
//  Copyright © 2016 Hey Danno. All rights reserved.
//

import Foundation

public extension NSMutableURLRequest {
    
    /// Create a mutable URL request
    /// parameter serviceRequest: The service request to convert
    public convenience init(_ serviceRequest: ServiceRequest) {
        let finalUrl: NSURL
        if let query = serviceRequest.query, components = NSURLComponents(URL: serviceRequest.url, resolvingAgainstBaseURL: false) {
            for (name, rawValue) in query {
                components.appendQueryStringValue(rawValue, withName: name)
            }
            finalUrl = components.URL!
        } else {
            finalUrl = serviceRequest.url
        }
        self.init(URL: finalUrl)
        self.HTTPMethod = serviceRequest.method.rawValue
        if let headers = serviceRequest.headers {
            for (header, value) in headers {
                self.setValue(value, forHTTPHeaderField: header)
            }
        }
        if let body = serviceRequest.body where serviceRequest.method.allowsBody {
            self.HTTPBody = body.data
        }
    }
    
}