//
//  Created by Shady
//  All rights reserved.
//  

import XCTest
import TvShows

class TvShowsAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGET_matchesFixedAccountData(){
        let url  = URL(string: "https://tvjan-tvmaze-v1.p.rapidapi.com/shows/15779")!
        let client = URLSessionHTTPClient()
        let headers = [
            "x-rapidapi-host": "tvjan-tvmaze-v1.p.rapidapi.com",
            "x-rapidapi-key": "d3700121f3mshf6b090f2b27b01dp18d7a9jsn239b336ab56a"
        ]

        let exp = expectation(description: "Wait for completion")
        let expectedShow = Show(id: 15779, name: "CBS News Sunday Morning", language: "English", status: "Running",genres: [])
        var receivedResult : ShowLoaderResult?
        let loader = RemoteShowLoader(url: url, headers: headers, client: client)

        loader.load { (result) in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

        switch receivedResult {
        case let .success(show)?:
            XCTAssertNotNil(show)
            XCTAssertEqual(show, expectedShow)
        case let .failure(error):
            XCTFail("Expected Success got fail with \(error)")
        default:
            XCTFail("Expected Success got fail")
        }
    }

//    func test_load_makeSureJSON(){
//        let data = Data("".utf8)
//        let dataFromResponse = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
//        dataFromResponse.forEach{(k,v) in
//            print("\(k) : \(v)")
//        }
//        do {
//            let remoteTvShow = try JSONDecoder().decode(RemoteTvShow.self, from: data)
//        }
//        catch{
//            print("\(error)")
//        }
//    }


}
