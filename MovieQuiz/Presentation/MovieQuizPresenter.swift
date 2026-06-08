import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate{
    private let questionsAmount: Int = 10
    private var correctAnswer: Int = 0
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol!
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
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
    
    //Проверка наличия следующего вопроса
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
   
    //Проверка последнего вопроса
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    //Проверка правильности ответа
    func didAnswer(isCorrectAnswer: Bool){
        if isCorrectAnswer {
            correctAnswer += 1
        }
    }
    
    //Функция начала новой игры
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswer = 0
        questionFactory?.requestNextQuestion()
    }
    
    //Функция перехода к следующему вопросу
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    //Функция конвертации вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(), question: model.text, questionNumber: questionNumber)
    }
    
    //Функция нажатия кнопки Да
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
   
    //Функция нажатия кнопки нет
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    //Вспомогательная функция наэатия на кнопку ответа
    private func didAnswer(isYes: Bool){
        guard let currentQuestion = currentQuestion else {
            return
        }
        let answer = isYes
        proceedWithAnswer(isCorrect: answer == currentQuestion.correctAnswer)
    }
  
    //Функция отображения результата ответа
    private func proceedToNextQuestionOrResult(){
        if self.isLastQuestion() {
            let result = QuizResultViewModel(title: "Этот раунд окончен",
                                       text: "Ваш результат: \(correctAnswer)/\(questionsAmount)",
                                       buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: result)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    //Функция отображения результата ответа
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        viewController?.toggleButtons(isEnabled: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){[weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResult()
            self.viewController?.toggleButtons(isEnabled: true)
        }
    }
    
    //Функция генерации сообщения статистики
    func makeStatisticMessage(current gameMessage: String) -> String{
        statisticService.store(correct: correctAnswer, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
    
        let statMessage = """
           \(gameMessage)
           Количество сыграных квизов: \(statisticService.gamesCount)
           Рекород: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
           Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
           """
        return statMessage
    }
}
