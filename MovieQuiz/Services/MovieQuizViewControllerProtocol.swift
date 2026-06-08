import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject{
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultViewModel)
    
    func highlightImageBorder(isCorrect: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func toggleButtons(isEnabled: Bool)
    
    func showNetworkError(message: String)
}
