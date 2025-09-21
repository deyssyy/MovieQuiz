import Foundation
import XCTest
@testable import MovieQuiz

protocol MoviesLoading {
    typealias CompletionHandler = (_ result: Result<MostPopularMovies, Error>) -> Void
    func loadMovie(completion: @escaping CompletionHandler)
}

class MockMoviesLoader: MoviesLoading {
    let mockResult: Result<MostPopularMovies, Error>
    
    init(mockResult: Result<MostPopularMovies, Error>) {
        self.mockResult = mockResult
    }
    
    func loadMovie(completion: @escaping CompletionHandler) {
        completion(mockResult)
    }
}

struct MostPopularMovie {
    let id: String
    let title: String
    let resizedImageUrl: URL
    let rating: Double
}

final class MockQuestionFactoryDelegate: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        
    }
    
    func didFailToLoadDataFromServer(with error: any Error) {
        
    }
    
    var receivedQuestion: QuizQuestion?
    func didReceiveNextQuestion(question: QuizQuestion?) {
        receivedQuestion = question
    }
}

class QuestionFactoryTests: XCTestCase {
    var sut: QuestionFactory!
    var mockLoader: MockMoviesLoader!
    var mockDelegate: MockQuestionFactoryDelegate!
      
      override func setUp() {
          super.setUp()
          mockLoader = MockMoviesLoader(
            mockResult: .success(MostPopularMovies(items: [
                MostPopularMovie(resizedImageUrl: URL(string: "https://example.com/image.jpg")!, rating: "8"),
                MostPopularMovie(resizedImageUrl: URL(string: "https://example.com/image2.jpg")!, rating: "6")
            ]))

          mockDelegate = MockQuestionFactoryDelegate()
          sut = QuestionFactory(delegate: mockDelegate, moviesLoader: mockLoader)
          let expectation = expectation(description: "Requesting next question")
          sut.loadData()
          expectation.fulfill()
          waitForExpectations(timeout: 1)
      }
      
      override func tearDown() {
          sut = nil
          mockLoader = nil
          mockDelegate = nil
          super.tearDown()
      }
    
    func testRequestNextQuetion() throws{
        let expectation = expectation(description: "Requesting next question")
        sut.requestNextQuestion()
        expectation.fulfill()
        XCTAssertNotNil(mockDelegate.receivedQuestion)
        
        waitForExpectations(timeout: 5)
    }
}


