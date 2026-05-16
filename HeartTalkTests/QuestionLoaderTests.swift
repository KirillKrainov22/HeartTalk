import XCTest
@testable import HeartTalk

final class QuestionLoaderTests: XCTestCase {

    func test_load_decodesBundledQuestions() {
        let loader = QuestionLoader(bundle: .main)
        let exp = expectation(description: "load")
        loader.load { result in
            switch result {
            case .success(let questions):
                XCTAssertFalse(questions.isEmpty)
                let cats = Set(questions.map { $0.category })
                XCTAssertEqual(cats, Set(QuestionCategory.allKeys))
            case .failure(let err):
                XCTFail("expected success, got \(err)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
    }

    func test_load_completesOnMainQueue() {
        let loader = QuestionLoader()
        let exp = expectation(description: "main")
        loader.load { _ in
            XCTAssertTrue(Thread.isMainThread)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
    }

    func test_load_missingResource_returnsFailure() {
        let loader = QuestionLoader(bundle: .main, resourceName: "nonexistent_file_xyz")
        let exp = expectation(description: "fail")
        loader.load { result in
            if case .failure(.fileNotFound) = result {
                exp.fulfill()
            } else {
                XCTFail("expected fileNotFound, got \(result)")
            }
        }
        wait(for: [exp], timeout: 2)
    }
}
