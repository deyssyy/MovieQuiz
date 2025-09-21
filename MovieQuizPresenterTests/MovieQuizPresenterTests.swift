import XCTest
@testable import MovieQuiz

final class MovieQuizVeiwControllerMock: MovieQuizViewControllerProtocol{
    func toggleButtons(isEnabled: Bool) {
        
    }
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func show(quiz result: MovieQuiz.QuizResultViewModel) {
       
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func showNetworkError(message: String) {
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws{
        let viewControllerMock = MovieQuizVeiwControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question test", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question test")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
    
    func testmakeStatisticMessage() throws{
        let viewControllerMock = MovieQuizVeiwControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let testString = sut.makeStatisticMessage(current: "1")
        
        XCTAssertNotNil(testString)
    }
}
