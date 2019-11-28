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
    case patch = "PATCH"
}

internal class EmptyObject: Codable {
}

class SessionManager: NSObject {
    public typealias RequestInterceptor = (_ urlRequest: URLRequest?) -> Void
    public typealias ResponseInterceptor = (_ urlResponse: URLResponse?, _ error: Error?) -> Void

    public static var session: URLSession = URLSession.shared
    public static var requestInterceptors: [RequestInterceptor?] = [] // Called before request
    public static var responseInterceptors: [ResponseInterceptor?] = [] // Called after response
}

enum NetErr: Error {
    case runtimeError(String)
}

struct Result <ResObj: Decodable> {
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

    func getStatusCode() -> Int {
        if let response = urlResponse as? HTTPURLResponse {
            return response.statusCode
        }
        return -1
    }

    private func getHeaders() -> [String: String] {
        var headers: [String: String] = [:]
        if let response = urlResponse as? HTTPURLResponse {
            response.allHeaderFields.forEach({ (key, value) in
                if let key = key as? String, let value = value as? String {
                    headers[key.lowercased()] = value
                }
            })
            return headers
        }
        return headers
    }

    func getHeader(_ key: String) -> String? {
        return getHeaders()[key.lowercased()]
    }
}

/** Used when you want to just download an content without any serialization or deserialization. Eg: load images */
typealias Download = RequestManager<EmptyObject, EmptyObject>

/** Used when you want to send an object in request and deserialize the object at response */
typealias RequestAndResponse<ReqObj: Encodable, ResObj: Decodable> = RequestManager<ReqObj, ResObj>

/** Used to send an object at request but do not expect a deserializable response  */
typealias Request<ReqObj: Encodable> = RequestManager<ReqObj, EmptyObject>

/** Receive a deserializable response */
typealias Response<ResObj: Decodable> = RequestManager<EmptyObject, ResObj>

typealias Call = RequestManager<EmptyObject, EmptyObject>

class RequestManager<ReqObj: Encodable, ResObj: Decodable> {

    typealias RequestResponseHandler = (_ res: Result<ResObj>) -> Void
    typealias DownloadResponse = (_ temporaryPath: URL, _ urlResponse: URLResponse) -> Void // URL with temporary File name

    private var urlRequest: URLRequest

    // Events
    private var onHttpErrorHandler: RequestResponseHandler? // Eg: Connection Lost, No internet Connection, etc... (When the app can't connect with the server)
    private var onDataErrorHandler: RequestResponseHandler? // Eg: Internal Server Errors, Bad Request... (When the app can connect with the server, but the server returned an error code)
    private var onError: RequestResponseHandler? // Used to catch any error type (http error and data parse error) using method .catch instead of .onHttpError and .OnDataError

    private var dataTask: URLSessionDataTask?
    private var downloadTask: URLSessionDownloadTask?

    init(_ url: URL) {
        self.urlRequest = URLRequest(url: url)
    }

    convenience init(_ url: URL, _ data: ReqObj) {
        self.init(url)
        self.urlRequest.httpBody = try? JSONEncoder().encode(data)
        self.urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    }

    func setHeader(withName name: String, andValue value: String?) -> RequestManager<ReqObj, ResObj> {
        self.urlRequest.setValue(value, forHTTPHeaderField: name)
        return self
    }

    func setAuth(_ authorization: String?) -> RequestManager<ReqObj, ResObj> {
        return setHeader(withName: "Authorization", andValue: authorization)
    }

    func setHeaders(_ headers: [String: String?]) -> RequestManager<ReqObj, ResObj> {
        headers.forEach { (name, value) in
            self.urlRequest.setValue(value, forHTTPHeaderField: name)
        }
        return self
    }

    func setBody(_ data: Data?) -> RequestManager<ReqObj, ResObj> {
        self.urlRequest.httpBody = data
        return self
    }

    func setBody(_ data: ReqObj?) -> RequestManager<ReqObj, ResObj> {
        self.urlRequest.httpBody = try? JSONEncoder().encode(data)
        self.urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return self
    }

    func setQueryParams(_ params: [String: String]) -> RequestManager<ReqObj, ResObj> {
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
    func onDataError(_ completion: RequestResponseHandler?) -> RequestManager<ReqObj, ResObj> {
        self.onDataErrorHandler = completion
        return self
    }

    @discardableResult
    func onHttpError(_ completion: RequestResponseHandler?) -> RequestManager<ReqObj, ResObj> {
        self.onHttpErrorHandler = completion
        return self
    }

    @discardableResult
    func get(_ onComplete: RequestResponseHandler? = nil) -> RequestManager<ReqObj, ResObj> {
        self.urlRequest.httpMethod = HTTPMethod.get.rawValue
        self.urlRequest.httpBody = nil
        return onComplete != nil ? execute(onComplete) : self
    }

    @discardableResult
    func post(_ onComplete: RequestResponseHandler? = nil) -> RequestManager<ReqObj, ResObj> {
        self.urlRequest.httpMethod = HTTPMethod.post.rawValue
        return onComplete != nil ? execute(onComplete) : self
    }

    @discardableResult
    func put(_ onComplete: RequestResponseHandler? = nil) -> RequestManager<ReqObj, ResObj> {
        self.urlRequest.httpMethod = HTTPMethod.put.rawValue
        return onComplete != nil ? execute(onComplete) : self
    }

    @discardableResult
    func delete(_ onComplete: RequestResponseHandler? = nil) -> RequestManager<ReqObj, ResObj> {
        self.urlRequest.httpMethod = HTTPMethod.delete.rawValue
        return onComplete != nil ? execute(onComplete) : self
    }
    
    @discardableResult
    func patch(_ onComplete: RequestResponseHandler? = nil) -> RequestManager<ReqObj, ResObj> {
        self.urlRequest.httpMethod = HTTPMethod.patch.rawValue
        self.urlRequest.httpBody = nil
        return onComplete != nil ? execute(onComplete) : self
    }

    @discardableResult
    func onComplete(_ onComplete: RequestResponseHandler?) -> RequestManager<ReqObj, ResObj> {
        return execute(onComplete)
    }

    func cancelTask() {
        self.dataTask?.cancel()
        self.downloadTask?.cancel()
    }

    @discardableResult
    func catchError (_ completion: RequestResponseHandler?) -> RequestManager<ReqObj, ResObj> {
        self.onError = completion
        return self
    }

    // swiftlint:disable function_body_length
    private func execute(_ onComplete: RequestResponseHandler?) -> RequestManager<ReqObj, ResObj> {
        SessionManager.requestInterceptors.forEach { (callback) in
            callback?(self.urlRequest)
        }
        let task = SessionManager.session.dataTask(with: self.urlRequest) { (data, urlResponse, error) in
            SessionManager.session.getAllTasks(completionHandler: { (tasks) in
                if (tasks.count == 0) {
                    DispatchQueue.main.async {

                    }
                }
            })
            DispatchQueue.main.async {

            }
            SessionManager.responseInterceptors.forEach({ interceptor in
                interceptor?(urlResponse, error)
            })
            if let error = error { // Deu erro de HTTP
                let response = Result<ResObj>(object: nil, data: data, urlResponse: urlResponse, error: error)
                (self.onError != nil) ? self.onError?(response) : self.onHttpErrorHandler?(response)
                return
            } else if ResObj.self != EmptyObject.self { // Recebeu os dados do backend
                do {
                    guard let data = data else { // Se o servidor não retornar os dados
                        let response = Result<ResObj>(object: nil, data: nil, urlResponse: urlResponse, error: error)
                        (self.onError != nil) ? self.onError?(response) : self.onDataErrorHandler?(response)
                        #if DEBUG
                        if let error = error { print(error) }
                        #endif
                        return
                    }
                    if !self.isSuccessfulHttpCode(response: urlResponse) {
                        let response = Result<ResObj>(object: nil, data: data, urlResponse: urlResponse, error: error)
                        (self.onError != nil) ? self.onError?(response) : self.onDataErrorHandler?(response)
                        #if DEBUG
                        if let error = error { print(error) }
                        #endif
                        return
                    }
                    let object = try JSONDecoder().decode(ResObj.self, from: data) // Tenta decodificar
                    let response = Result<ResObj>(object: object, data: data, urlResponse: urlResponse, error: error)
                    onComplete?(response)
                } catch { // Se deu erro na decodificação
                    let response = Result<ResObj>(object: nil, data: data, urlResponse: urlResponse, error: error)
                    #if DEBUG
                    print(error)
                    #endif
                    (self.onError != nil) ? self.onError?(response) : self.onDataErrorHandler?(response)
                }
            } else { // Response não mapeavel
                if self.isSuccessfulHttpCode(response: urlResponse) {
                    let response = Result<ResObj>(object: nil, data: data, urlResponse: urlResponse, error: error)
                    onComplete?(response)
                } else {
                    let response = Result<ResObj>(object: nil, data: data, urlResponse: urlResponse, error: error)
                    (self.onError != nil) ? self.onError?(response) : self.onDataErrorHandler?(response)
                    #if DEBUG
                    if let error = error { print(error) }
                    #endif
                }

            }
        }
        self.dataTask = task
        task.resume()
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
    func download(withMethod: HTTPMethod, _ onComplete: DownloadResponse?) -> RequestManager<ReqObj, ResObj> {
        self.urlRequest.httpMethod = withMethod.rawValue
        self.urlRequest.cachePolicy = .useProtocolCachePolicy
        var cachedResponse: CachedURLResponse?
        if let cached = URLCache.shared.cachedResponse(for: urlRequest) {
            cachedResponse = cached
        }
        let task = SessionManager.session.downloadTask(with: self.urlRequest) { (temporaryFileName, urlResponse, error) in
            if let error = error { // Deu erro de HTTP
                let response = Result<ResObj>(object: nil, data: nil, urlResponse: urlResponse, error: error)
                self.onHttpErrorHandler?(response)
            } else if let path = temporaryFileName, let urlResponse = urlResponse {
                onComplete?(path, urlResponse)
                if let data = try? Data(contentsOf: path), cachedResponse == nil {
                    URLCache.shared.storeCachedResponse(CachedURLResponse(response: urlResponse, data: data), for: self.urlRequest)
                }
            }
        }
        task.resume()
        self.downloadTask = task
        return self
    }

}
