//
//  ExecutiveRequestHandler.swift
//  Requester
//
//  Created by Pavlo Dumyak on 20.11.2020.
//

import Foundation

open class ExecutiveRequestHandler: RequestHandler {
    
    override func processRequest<T>(request: Request, error: Error?, type: T.Type) where T : Decodable {
        var error = error
        
        let serviceRequest = request.buildURLRequest()
        
        let methodStart = Date()
        let semaphore = DispatchSemaphore.init(value: 0)
        let task = URLSession.shared.dataTask(with: serviceRequest) { data, response, networkError in
            if request.canceled {
                print("request cancelled: \(request)")
            } else if let networkError = networkError {
                error = networkError
            }
            
            let result = RequestParser().parse(object: data, objectType: type, response: response)
            switch result {
            case .success:
                request.onSuccess?(Request.SuccessResponse(response: response,
                                                           object: data,
                                                           parsedObject: nil))
            case .successWith(object: let object):
                request.onSuccess?(Request.SuccessResponse(response: response,
                                                           object: data,
                                                           parsedObject: object))
            case .failed(error: let error):
                request.onFail?(Request.FailResponse(response: response,
                                                     error: error))
            }
            
            let methodFinish = Date()
            let executionTime = methodFinish.timeIntervalSince(methodStart)
            URLSession.shared.reset {}
            semaphore.signal()
        }
        
        task.resume()
        
        if semaphore.wait(timeout: DispatchTime.distantFuture) == .timedOut {
            // TODO: handle timeout (throw error)
        }
        
        super.processRequest(request: request, error: error, type: type)
    }
}
