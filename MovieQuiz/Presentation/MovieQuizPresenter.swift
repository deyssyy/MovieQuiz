import UIKit

final class MovieQuizPresenter{
    let questionsAmount: Int = 10
    var correctAnswer: Int = 0
    private var currentQuestionIndex = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetCurrentQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(), question: model.text, questionNumber: questionNumber)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
   
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool){
        guard let currentQuestion = currentQuestion else {
            return
        }
        let answer = isYes
        viewController?.showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
                return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    //Функция отображения результата ответа
    func showNextQuestionOrResult(){
        if self.isLastQuestion() {
            let result = QuizResultViewModel(title: "Этот раунд окончен", text: "Ваш результат: \(correctAnswer)/\(questionsAmount)", buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: result)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            //previewImage.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
