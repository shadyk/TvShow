//
//  Created by Shady
//  All rights reserved.
//  

import Foundation

public class URLSessionHTTPClient : HTTPClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }
    struct UnexpectedValueRepresentaiton : Error {}

    public func get(url: URL, completion: @escaping (HttpClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data, let response = response as? HTTPURLResponse{
                completion(.success(data, response))
            }
            else{
                completion(.failure(UnexpectedValueRepresentaiton()))
            }
        }.resume()
    }
}
