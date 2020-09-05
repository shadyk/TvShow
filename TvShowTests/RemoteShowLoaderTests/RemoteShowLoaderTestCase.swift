//
//  RemoteShowLoader.swift
//  TvShowsTests
//
//  Created by Shady Kahaleh on 7/26/20.
//

import XCTest
import TvShows

class RemoteShowLoaderTestCase: XCTestCase {

    func test_init_doesntLoadWhenCreated(){
        let (_,client) = makeSUT(url: anyURL())
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    func test_load_whenURLCalled(){
        let url = anyURL()
        let (remoteLoader,client) = makeSUT(url: url)

        remoteLoader.load{_ in }

        XCTAssertEqual(client.requestedURLs,[url])
    }

    func test_load_twice(){
        let url = anyURL()
        let (remoteLoader,client) = makeSUT(url: url)

        remoteLoader.load{_ in }
        remoteLoader.load {_ in }

        XCTAssertEqual(client.requestedURLs,[url,url])
    }

    func test_load_deliversErrorOnClient(){
        let (sut,client) = makeSUT(url: anyURL())

        expect(sut, toCompleteWith: .failure(RemoteShowLoader.Error.connectivity), when: {
            client.complete(with: NSError())
        })

    }

    func test_load_completesWithStatusCodeNot200(){
        let (sut,client) = makeSUT(url: anyURL())

        let samples = [199,201,400,500]
        samples.enumerated().forEach{ index,code in
            expect(sut, toCompleteWith: .failure(RemoteShowLoader.Error.invalidData), when: {
                let notFoundData = Data("{\"name\":\"Not Found\"}".utf8)
                client.complete(withStatusCode: code,data:notFoundData, at: index)
            })
        }
    }

    func test_load_completesWithStatusCode200InValidJson(){
        let (sut,client) = makeSUT(url: anyURL())

        expect(sut,
               toCompleteWith: .failure(RemoteShowLoader.Error.invalidData),
               when: {
                let invalidJsonData = Data("non json string".utf8)
                client.complete(withStatusCode: 200, data: invalidJsonData)}
        )
    }

    func test_load_completesWithSuccessNotFound(){
        let (sut,client) = makeSUT(url: anyURL())

        expect(sut,
               toCompleteWith: .failure(RemoteShowLoader.Error.notFound),
               when: {
            let notFoundData = Data("{\"name\":\"Not Found\",\"status\":404, \"code\":0,\"message\":\"not found\"}".utf8)
                client.complete(withStatusCode: 200, data: notFoundData)
        })
    }

    func test_load_completesWithSuccessItem(){
        let (sut,client) = makeSUT(url: anyURL())
        let item = makeItem(id: UUID(), name: "name", language: "english", status: "Ended", genres: ["comedy"])

        expect(sut,
               toCompleteWith: .success(item.model),
               when: {
                let data = makeItemJSON(item.json)
                client.complete(withStatusCode: 200, data: data)
            })
    }

    func test_load_doesntSucceedWhenSUTisDeallocated(){
        //this means if remoteloader became nil and client completes, we should not run the completions i.e. capturedResults
        let client = HTTPClientSpy()
        var sut :RemoteShowLoader? = RemoteShowLoader(url: anyURL(), client:client )
        var capturedResults = [RemoteShowLoader.Result]()

        sut?.load { capturedResults.append($0) }
        sut = nil
        client.complete(withStatusCode: 200, data: Data("any data".utf8))

        XCTAssertTrue(capturedResults.isEmpty)

    }


    //MARK:- helpers

    //MAKE SUT
    private func makeSUT(url:URL,file: StaticString = #file, line: UInt = #line) -> (RemoteShowLoader, HTTPClientSpy) {

        let client = HTTPClientSpy()
        let sut = RemoteShowLoader(url: url, client: client)
        trackForMemoryLeak(client,file: file,line: line)
        trackForMemoryLeak(sut,file: file,line: line)
        return (sut,client)
    }


    //CLEINT SPY
    private class HTTPClientSpy: HTTPClient{
        var messages = [(url:URL,completion: (HttpClientResult) -> Void)]()
        var requestedURLs : [URL]  {
            return messages.map{$0.url}
        }

        func get(url: URL, completion: @escaping (HttpClientResult) -> Void) {
            messages.append((url:url,completion:completion))
        }

        func complete(with error: Error, at index:Int = 0){
            messages[index].completion(.failure(error))
        }

        func complete(withStatusCode: Int, data:Data,at index:Int = 0){
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: withStatusCode, httpVersion: nil, headerFields: nil)
            messages[index].completion(.success(data, response!))
        }

    }


    //HELPER
    private func anyURL() -> URL{
        return URL(string:"http://any-url.com")!
    }

    private func expect(_ sut: RemoteShowLoader, toCompleteWith expectedResult: RemoteShowLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

            case let (.failure(receivedError as RemoteShowLoader.Error), .failure(expectedError as RemoteShowLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func trackForMemoryLeak(_ instance:AnyObject,file: StaticString = #file, line: UInt = #line){
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance,"instance Should deallocate after using. Potenial memory leak",file: file,line: line)
        }
    }


    private func makeItem(id: UUID, name: String, language: String,status:String, genres:[String]) -> (model: Show, json: [String: Any]) {
        let item = Show(id: id, name: name, language: language, status: status,genres: genres)

        let json = [
            "id": id.uuidString,
            "name": name,
            "language": language,
            "genres" : genres,
            "status" : status,
        ].compactMapValues { $0 }

        return (item, json)
    }

    private func makeItemJSON(_ item: [String: Any]) -> Data {
        return try! JSONSerialization.data(withJSONObject: item)
    }


}

//type: Scripted
//premiered: 1973-03-26
//genres: (
//    Drama,
//    Family,
//    Romance
//)
//status: Running
//runtime: 60
//officialSite: http://www.cbs.com/shows/the_young_and_the_restless/
//externals: {
//    imdb = tt0069658;
//    thetvdb = 70328;
//    tvrage = 6318;
//}
//weight: 96
//url: http://www.tvmaze.com/shows/4344/the-young-and-the-restless
//language: English
//_links: {
//    nextepisode =     {
//        href = "http://api.tvmaze.com/episodes/1910518";
//    };
//    previousepisode =     {
//        href = "http://api.tvmaze.com/episodes/1910517";
//    };
//    self =     {
//        href = "http://api.tvmaze.com/shows/4344";
//    };
//}
//schedule: {
//    days =     (
//        Monday,
//        Tuesday,
//        Wednesday,
//        Thursday,
//        Friday
//    );
//    time = "12:30";
//}
//network: {
//    country =     {
//        code = US;
//        name = "United States";
//        timezone = "America/New_York";
//    };
//    id = 2;
//    name = CBS;
//}
//summary: <p><b>The Young and the Restless</b> revolves around the rivalries, romances, hopes and fears of the residents of the fictional Midwestern metropolis, Genoa City. The lives and loves of a wide variety of characters mingle through the generations, dominated by the Newman, Abbott, Chancellor, Baldwin and Winters families. ­ When The Young and the Restless premiered in 1973, it revolutionized the daytime drama. It continues to set the standard with strong characters, socially conscious storylines, romance and sensuality.</p>
//rating: {
//    average = "6.4";
//}
//webChannel: <null>
//updated: 1597006008
//image: {
//    medium = "http://static.tvmaze.com/uploads/images/medium_portrait/233/583614.jpg";
//    original = "http://static.tvmaze.com/uploads/images/original_untouched/233/583614.jpg";
//}
//id: 4344
//name: The Young and the Restless
