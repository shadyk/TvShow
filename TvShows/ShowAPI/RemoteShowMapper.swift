//
//  RemoteShowMapper.swift
//  TvShows
//
//  Created by Shady Kahaleh on 8/16/20.
//

import Foundation

final class RemoteShowMapper{

    private struct RemoteTvShow : Decodable{
        var id : UUID
        var name: String
        var language: String
        var genres : [String]?
        var status : String
        var message : String?
        var code : Int?

        func map()->TvShow{
            return TvShow(id: self.id, name: self.name, language: self.language, status:    self.status,genres: self.genres)
        }
    }

    private struct ErrorObject : Decodable {
        var status : Int
        var message : String
        var code : Int
        var name : String
    }

    static func map(data:Data,response:HTTPURLResponse) -> RemoteShowLoader.Result{
        guard response.statusCode == 200 else{
            return .failure(.invalidData)
        }

        if  let json = try? JSONDecoder().decode(RemoteTvShow.self, from: data) {
            return .success(json.map())
        }
        else if let _ = try? JSONDecoder().decode(ErrorObject.self, from: data){
            return.failure(.notFound)
        }
        else{
            return.failure(.invalidData)
        }
     }
}
