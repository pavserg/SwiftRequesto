//
//  Requester.swift
//  Requester
//
//  Created by Pavlo Dumyak on 20.11.2020.
//

import Foundation

open class Requester {
    
    static public let shared = Requester()
    
    private var centralRequestHandler = CentralRequestHandler()
    
    private init() {
        centralRequestHandler.nextHandler = ExecutiveRequestHandler()
    }
    
    func processRequestAsynchronously<T: Decodable>(request: Request, type: T.Type) {
        centralRequestHandler.processRequestAsynchronously(request: request, error: nil, type: type)
    }
    
    func processRequestSynchronously<T: Decodable>(request: Request, type: T.Type) {
        centralRequestHandler.processRequestSynchronously(request: request, error: nil, type: type)
    }
    
    public func cancelAllRequests(owner: ObjectIdentifier) {

    }
    
    public func cancellAllRequests() {
  
    }
}
