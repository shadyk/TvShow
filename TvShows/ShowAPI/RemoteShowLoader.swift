//
//  RemoteShowLoader.swift
//  TvShows
//
//  Created by Shady Kahaleh on 7/31/20.
//

import Foundation

//protocol ShowLoader{
//    func load(completion:((Error) -> Void)?)
//}

public enum HttpClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient{

    func get(url:URL, completion: @escaping(HttpClientResult) -> Void)
}


public final class RemoteShowLoader {
    private let url : URL
    private let client : HTTPClient

    public enum Error : Swift.Error {
        case connectivity
        case invalidData
        case notFound
    }

    public enum Result : Equatable {
        case success(TvShow?)
        case failure(Error)
    }

    public init(url:URL, client:HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion:@escaping (Result) -> Void) {
        client.get(url: url){ result in
            switch result {
            case let .success(data,response):

                if response.statusCode == 200 {
                    if  let json = try? JSONDecoder().decode(TvShow.self, from: data) {
                        completion(.success(json))
                    }
                    else if let _ = try? JSONDecoder().decode(ErrorObject.self, from: data){
                        completion(.failure(.notFound))
                    }
                    else{
                             completion(.failure(.invalidData))
                         }
                }
                else{
                    completion(.failure(.invalidData))
                }

            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}





