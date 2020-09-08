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
        case let .failure(error):
            XCTFail("Expected Success got fail with \(error)")
        default:
            XCTFail("Expected Success got fail")
        }

    }

}
