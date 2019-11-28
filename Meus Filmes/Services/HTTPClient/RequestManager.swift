//
//  RequestManager.swift
//  Meus Filmes
//
//  Created by Igor Vilar on 27/11/19.
//  Copyright © 2019 Igor Vilar. All rights reserved.
//

import UIKit

public enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
    case connect = "CONNECT"
}

internal class EmptyObject: Codable {
}

@objc class SessionManager: NSObject {
    public typealias RequestInterceptor = (_ urlRequest: URLRequest?) -> Void
    public typealias ResponseInterceptor = (_ urlResponse: URLResponse?, _ error: Error?) -> Void
    
    @objc public static var session: URLSession = URLSession.shared
    public static var requestInterceptors: [RequestInterceptor?] = [] // Called before request
    public static var responseInterceptors: [ResponseInterceptor?] = [] // Called after response
}

enum NetErr: Error {
    case runtimeError(String)
}

struct Response <ResObj: Decodable> {
    var object: ResObj?
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?

    /** Map a different object **/
    func mapData<T: Decodable>(_ objectType: T.Type) throws -> T {
        guard let data = self.data else {
            throw NetErr.runtimeError("Response data is null")
        }
        return try JSONDecoder().decode(objectType, from: data)
    }
}

/** Used when you want to just download an content without any serialization or deserialization. Eg: load images */
typealias Download = Request<EmptyObject, EmptyObject>

/** Used when you want to send an object in request and deserialize the object at response */
typealias ReqRes<ReqObj: Encodable, ResObj: Decodable> = Request<ReqObj, ResObj>

/** Used to send an object at request but do not expect a deserializable response  */
typealias Req<ReqObj: Encodable> = Request<ReqObj, EmptyObject>

/** Receive a deserializable response */
typealias Res<ResObj: Decodable> = Request<EmptyObject, ResObj>

class Request<ReqObj: Encodable, ResObj: Decodable> {
    
    typealias RequestResponse = (_ res: Response<ResObj>) -> Void
    typealias DownloadResponse = (_ temporaryPath: URL, _ urlResponse: URLResponse) -> Void // URL with temporary File name
    
    private var urlRequest: URLRequest
    
    // Events
    private var onHttpErrorHandler: RequestResponse? // Eg: Connection Lost, No internet Connection, etc... (When the app can't connect with the server)
    private var onDataErrorHandler: RequestResponse? // Eg: Internal Server Errors, Bad Request... (When the app can connect with the server, but the server returned an error code)
    private var onError: RequestResponse? // Used to catch any error type (http error and data parse error) using method .catch instead of .onHttpError and .OnDataError
        
    init(_ url: URL) {
        self.urlRequest = URLRequest(url: url)
    }

    convenience init(_ url: URL, _ data: ReqObj) {
        self.init(url)
        self.urlRequest.httpBody = try? JSONEncoder().encode(data)
        self.urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    }
    
    func setHeader(withName name: String, andValue value: String?) -> Request<ReqObj, ResObj> {
        self.urlRequest.setValue(value, forHTTPHeaderField: name)
        return self
    }
    
    func setHeaders(_ headers: [String: String?]) -> Request<ReqObj, ResObj> {
        headers.forEach { (name, value) in
            self.urlRequest.setValue(value, forHTTPHeaderField: name)
        }
        return self
    }
    
    func setBody(_ data: Data?) -> Request<ReqObj, ResObj> {
        self.urlRequest.httpBody = data
        return self
    }
    
    func setBody(_ data: ReqObj?) -> Request<ReqObj, ResObj> {
        self.urlRequest.httpBody = try? JSONEncoder().encode(data)
        self.urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return self
    }
    
    func setQueryParams(_ params: [String: String]) -> Request<ReqObj, ResObj> {
        let queryItems = params.map { (key, value) -> URLQueryItem in
            return URLQueryItem(name: key, value: value)
        }
        var components = URLComponents(url: self.urlRequest.url!, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        if let url = components?.url {
            self.urlRequest.url = url
        }
        return self
    }
    
    @discardableResult
    func onDataError(_ completion: RequestResponse?) -> Request<ReqObj, ResObj> {
        self.onDataErrorHandler = completion
        return self
    }
    
    @discardableResult
    func onHttpError(_ completion: RequestResponse?) -> Request<ReqObj, ResObj> {
        self.onHttpErrorHandler = completion
        return self
    }
    
    @discardableResult
    func get(_ onComplete: RequestResponse? = nil) -> Request<ReqObj, ResObj> {
        self.urlRequest.httpMethod = HTTPMethod.get.rawValue
        self.urlRequest.httpBody = nil
        return onComplete != nil ? execute(onComplete) : self
    }
    
    @discardableResult
    func post(_ onComplete: RequestResponse? = nil) -> Request<ReqObj, ResObj> {
        self.urlRequest.httpMethod = HTTPMethod.post.rawValue
        return onComplete != nil ? execute(onComplete) : self
    }
    
    @discardableResult
    func put(_ onComplete: RequestResponse? = nil) -> Request<ReqObj, ResObj> {
        self.urlRequest.httpMethod = HTTPMethod.put.rawValue
        return onComplete != nil ? execute(onComplete) : self
    }
    
    @discardableResult
    func delete(_ onComplete: RequestResponse? = nil) -> Request<ReqObj, ResObj> {
        self.urlRequest.httpMethod = HTTPMethod.delete.rawValue
        return onComplete != nil ? execute(onComplete) : self
    }
    
    @discardableResult
    func onComplete(_ onComplete: RequestResponse?) -> Request<ReqObj, ResObj> {
        return execute(onComplete)
    }

    @discardableResult
    func catchError (_ completion: RequestResponse?) -> Request<ReqObj, ResObj> {
        self.onError = completion
        return self
    }

    private func execute(_ onComplete: RequestResponse?) -> Request<ReqObj, ResObj> {
        SessionManager.requestInterceptors.forEach { (callback) in
            callback?(self.urlRequest)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        SessionManager.session.dataTask(with: self.urlRequest) { (data, urlResponse, error) in
            SessionManager.session.getAllTasks(completionHandler: { (tasks) in
                if (tasks.count == 0) {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            SessionManager.responseInterceptors.forEach({ interceptor in
                interceptor?(urlResponse, error)
            })
            if let error = error { // Deu erro de HTTP
                let response = Response<ResObj>(object: nil, data: data, urlResponse: urlResponse, error: error)
                (self.onError != nil) ? self.onError?(response) : self.onHttpErrorHandler?(response)
                return
            } else if ResObj.self != EmptyObject.self { // Recebeu os dados do backend
                do {
                    guard let data = data else { // Se o servidor não retornar os dados
                        let response = Response<ResObj>(object: nil, data: nil, urlResponse: urlResponse, error: error)
                        (self.onError != nil) ? self.onError?(response) : self.onDataErrorHandler?(response)
                        return
                    }
                    if !self.isSuccessfulHttpCode(response: urlResponse) {
                        let response = Response<ResObj>(object: nil, data: data, urlResponse: urlResponse, error: error)
                        (self.onError != nil) ? self.onError?(response) : self.onDataErrorHandler?(response)
                        return
                    }
                    let object = try JSONDecoder().decode(ResObj.self, from: data) // Tenta decodificar
                    let response = Response<ResObj>(object: object, data: data, urlResponse: urlResponse, error: error)
                    onComplete?(response)
                } catch { // Se deu erro na decodificação
                    let response = Response<ResObj>(object: nil, data: data, urlResponse: urlResponse, error: error)
                    (self.onError != nil) ? self.onError?(response) : self.onDataErrorHandler?(response)
                }
            } else { // Response não mapeavel
                let response = Response<ResObj>(object: nil, data: data, urlResponse: urlResponse, error: error)
                onComplete?(response)
            }
        }.resume()
        return self
    }
    
    private func isSuccessfulHttpCode(response: URLResponse?) -> Bool {
        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }
        switch httpResponse.statusCode {
        case 200 ... 299:
            return true
        default:
            return false
        }
    }
    
    @discardableResult
    func download(withMethod: HTTPMethod, _ onComplete: DownloadResponse?) -> Request<ReqObj, ResObj> {
        self.urlRequest.httpMethod = withMethod.rawValue
        self.urlRequest.cachePolicy = .useProtocolCachePolicy
        var cachedResponse: CachedURLResponse?
        if let cached = URLCache.shared.cachedResponse(for: urlRequest) {
            cachedResponse = cached
        }
        SessionManager.session.downloadTask(with: self.urlRequest) { (temporaryFileName, urlResponse, error) in
            if let error = error { // Deu erro de HTTP
                let response = Response<ResObj>(object: nil, data: nil, urlResponse: urlResponse, error: error)
                self.onHttpErrorHandler?(response)
            } else if let path = temporaryFileName, let urlResponse = urlResponse {
                onComplete?(path, urlResponse)
                if let data = try? Data(contentsOf: path), cachedResponse == nil {
                    URLCache.shared.storeCachedResponse(CachedURLResponse(response: urlResponse, data: data), for: self.urlRequest)
                }
            }
        }.resume()
        return self
    }
    
}
