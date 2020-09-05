//
//  Created by Shady
//  All rights reserved.
//  

import XCTest
import TvShows

class URLSessionHTTPClient : HTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
    struct UnexpectedValueRepresentaiton : Error {}
    func get(url: URL, completion: @escaping (HttpClientResult) -> Void) {
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

class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }

    func test_getFromURL_performsGETrequest(){
        //BY USING THIS METHOD WE CAN ALSO TEST THE BODY, QUERY PARAMETERS IN THE REQUEST OBSERVER
        let url = anyURL()
        let exp = expectation(description: "Wait for completion")
        URLProtocolStub.observeRequests{ request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(url: url, completion: {_ in })
        waitForExpectations(timeout: 0.1)
    }

    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()

        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)

        XCTAssertEqual(receivedError as NSError?, requestError)

    }

    // TESTING THE INVALID DATA THAT CAN OCCUR (data?, response?, error?)
    func test_getFromURL_failsOnAllInvalidCases() {

        let nonHttpResponse = URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName:  nil)

        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHttpResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHttpResponse, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHttpResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHttpResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHttpResponse, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHttpResponse, error: nil))
    }

    func test_getFromURL_deliversSuccesOnDataAndResponse(){
        let data = anyData()
        let response = anyHttpResponse()

        let (receivedData,receivedResponse) = resultValuesFor(data: data, response: response, error: nil)

        XCTAssertEqual(data, receivedData)
        XCTAssertEqual(response?.url, receivedResponse?.url)
        XCTAssertEqual(response?.statusCode, receivedResponse?.statusCode)
    }

    func test_getFromURL_deliversSuccessOnNilDataAndResponse(){

        let response = anyHttpResponse()

        let (receivedData,receivedResponse) = resultValuesFor(data: nil, response: response, error: nil)

        let emptyData = Data()
        XCTAssertEqual(emptyData, receivedData)
        XCTAssertEqual(response?.url, receivedResponse?.url)
        XCTAssertEqual(response?.statusCode, receivedResponse?.statusCode)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient{
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut,file: file, line:line)
        return sut
    }

    private func resultErrorFor(data : Data? , response: URLResponse? , error:Error?,file: StaticString = #file, line: UInt = #line) -> Error?{

        let result = resultFor(data: data, response: response, error: error,file: file,line: line)

        switch result {
            case  let .failure(error):
                return error
            default:
                XCTFail("Expected failure , got \(result) instead",file: file,line: line)
            return nil
        }
    }

    private func resultValuesFor(data : Data? , response: URLResponse? , error:Error?,file: StaticString = #file, line: UInt = #line) -> (Data?,HTTPURLResponse?){

        let result = resultFor(data: data, response: response, error: error,file: file,line: line)

        switch result {
        case  let .success(data,response):
            return (data,response)

        default:
            XCTFail("Expected success , got \(result) instead",file: file,line: line)
            return (nil,nil)
        }

    }

    private func resultFor(data : Data? , response: URLResponse? , error:Error?,file: StaticString = #file, line: UInt = #line) -> HttpClientResult{


        URLProtocolStub.stub(data: data, response: response, error: error)

        let sut = makeSUT(file:file,line:line)
        var receivedResult : HttpClientResult!

        let exp = expectation(description: "Wait for completion")
        sut.get(url: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)



        return receivedResult
    }


    private class URLProtocolStub: URLProtocol {
        private static var stub : Stub?
        private static var requestObserver : ((URLRequest)->Void)?

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }

        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }

        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }

        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        static func observeRequests(observer: @escaping (URLRequest)->Void){
            requestObserver = observer
        }

        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}
