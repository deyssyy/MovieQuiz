import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate{
    let questionsAmount: Int = 10
    var correctAnswer: Int = 0
    private var currentQuestionIndex = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
  
    //Функция отвечающая за запрос следующего вопроса и отображение индикатора загрузки
    func didLoadDataFromServer(){
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    //Функция отвечающая за показ алерта при неудачной загрузке данных из сети
    func didFailToLoadDataFromServer(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
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
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func didAnswer(isCorrectAnswer: Bool){
        if isCorrectAnswer {
            correctAnswer += 1
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswer = 0
        questionFactory?.requestNextQuestion()
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
  
    //Функция отображения результата ответа
    func showNextQuestionOrResult(){
        if self.isLastQuestion() {
            let result = QuizResultViewModel(title: "Этот раунд окончен", text: "Ваш результат: \(correctAnswer)/\(questionsAmount)", buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: result)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
