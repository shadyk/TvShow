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
                completion(RemoteShowMapper.map(data: data, response:response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}





