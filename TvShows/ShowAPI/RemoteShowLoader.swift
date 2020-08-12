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
    }

    public enum Result : Equatable {
        case success([TvShow])
        case failure(Error)
    }

    public init(url:URL, client:HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion:@escaping (Result) -> Void) {
        client.get(url: url){ result in
            switch result {
            case let .success(data,_):
                if let _ = try? JSONSerialization.jsonObject(with: data){
                    completion(.success([]))
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
