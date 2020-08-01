//
//  RemoteShowLoader.swift
//  TvShows
//
//  Created by Shady Kahaleh on 7/31/20.
//

import Foundation

public enum HTTPClientResult{
    case success(HTTPURLResponse)
    case failure
}

public protocol HTTPClient{

    func get(url:URL, completion:@escaping(HTTPClientResult)->Void)
}

//protocol ShowLoader{
//    func load(completion:((Error) -> Void)?)
//}

public final class RemoteShowLoader {
    private let url : URL
    private let client : HTTPClient

    public enum Error : Swift.Error   {
        case connectivity
        case invalidData
    }

    public init(url:URL, client:HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion:@escaping (Error?) -> Void)  {
        client.get(url: url){ result in
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}
