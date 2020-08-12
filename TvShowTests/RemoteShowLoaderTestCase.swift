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

        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            client.complete(with: NSError())
        })

    }

    func test_load_completesWithStatusCodeNot200(){
        let (sut,client) = makeSUT(url: anyURL())

        let samples = [199,201,400,500]
        samples.enumerated().forEach{ index,code in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                client.complete(with: code,at: index)
            })
        }
    }

    func test_load_completesWithStatusCode200InValidJson(){
        let (sut,client) = makeSUT(url: anyURL())

        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJsonData = Data("non json string".utf8)
            client.complete(withData: invalidJsonData)
        })
    }

    func test_load_completesWithSuccessEmpty(){
        let (sut,client) = makeSUT(url: anyURL())

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyData = Data("{\"key\":[]}".utf8)
            client.complete(withData: emptyData)
        })
    }



    //MARK:- helpers

    //MAKE SUT
    private func makeSUT(url:URL) -> (RemoteShowLoader, HTTPClientSpy) {

        let client = HTTPClientSpy()
        let sut = RemoteShowLoader(url: url, client: client)
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

        func complete(withData data: Data, at index:Int = 0){
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: 200, httpVersion: nil, headerFields: nil)

            messages[index].completion(.success(data, response!))
        }

        func complete(with statusCode: Int, at index:Int = 0){
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)
            messages[index].completion(.success(Data(), response!))
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

            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

}
