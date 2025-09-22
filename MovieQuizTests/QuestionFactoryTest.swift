import Foundation
import XCTest
@testable import MovieQuiz

final class MockQuestionFactoryDelegate: QuestionFactoryDelegate {
    var didLoadData = false
    var didLoadDataClosure: (() -> Void)?
    func didLoadDataFromServer() {
        didLoadData = true
        didLoadDataClosure?()
    }
    var didFailToLodDataClosure: (() -> Void)?
    var didFailToLoadData: Bool = false
    func didFailToLoadDataFromServer(with error: any Error) {
        didFailToLoadData = true
        didFailToLodDataClosure?()
    }

    var didReceiveNextQuestionClosure: (() -> Void)?
    var receivedQuestion: QuizQuestion?
    func didReceiveNextQuestion(question: QuizQuestion?) {
        receivedQuestion = question
        didReceiveNextQuestionClosure?()
    }
}

final class QuestionFactoryTests: XCTestCase {
    var stubNetworkClient: StubNetworkClient!
    var mockLoader: MoviesLoader!
    var mockDelegate: MockQuestionFactoryDelegate!
    var sut: QuestionFactory!
    
    override func setUp() {
        stubNetworkClient = StubNetworkClient(emulatedError: false)
        mockLoader = MoviesLoader(networkClient: stubNetworkClient)
        mockDelegate = MockQuestionFactoryDelegate()
        sut = QuestionFactory(delegate: mockDelegate, moviesLoader: mockLoader)
    }
    
    func testSuccesRequestNextQuetion() throws{
        let loadingExpectation = expectation(description: "Ожидание Успешной загрузки данных")
        sut.loadData()
        mockDelegate.didLoadDataClosure = {
            loadingExpectation.fulfill()
        }
        wait(for: [loadingExpectation], timeout: 1)
        XCTAssertTrue(mockDelegate.didLoadData)
        let requestExpectation = expectation(description: "Запрос следующего вопроса")
        sut.requestNextQuestion()
        mockDelegate.didReceiveNextQuestionClosure = {
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 1)
        XCTAssertNotNil(mockDelegate.receivedQuestion)
    }
}

