import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate{

    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var nobutton: UIButton!
    @IBOutlet private weak var yesbutton: UIButton!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex = 0
    private var correctAnswer = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactory?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFont()
        setupImageView()
        showLoadingIndicator()
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.loadData()
        statisticService = StatisticService()
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
                return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
               self?.show(quiz: viewModel)
        }
    }
    
    //Нажатие на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let answer = true
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    //Нажатие на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let answer = false
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    //Функция отвечающая за запрос следующего вопроса и отображение индикатора загрузки
    func didLoadDataFromServer(){
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    //Функция отвечающая за показ алерта при неудачной загрузке данных из сети
    func didFailToLoadDataFromServer(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    //Функция отвечающая за показ и старт анимации у индикатора загрузки
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    //Функция отвечающая за скрытие и остановку анимации у индикатора загрузки
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    
    //Функция отвечающая за создание алерта при неудачной загрузке из сети
    private func showNetworkError(message: String){
        hideLoadingIndicator()
        let title = "Ошибка"
        let buttonText = "Попробовать ещё раз"
        let alert = AlertModel(title: title,
                           message: message,
                           buttonText: buttonText) {[weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswer = 0
            self.questionFactory?.requestNextQuestion()
        }
        AlertPresenter.alertPresten(vc: self, alertModel: alert)
    }
    
    //Функция для установки шрифтов
    private func setupFont(){
        let fontBold = UIFont.ysDisplayBold(size: 23)
        let fontMedium = UIFont.ysDisplayMedium(size: 20)
        questionLabel.font = fontBold
        questionLabel.text = ""
        indexLabel.font = fontMedium
        yesbutton.titleLabel?.font = fontMedium
        nobutton.titleLabel?.font = fontMedium
        questionTitleLabel.font = fontMedium
    }
    
    //функция настройки рвмки изображения
    private func setupImageView(){
        previewImage.isHidden = true
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.cornerRadius = 20
        previewImage.layer.borderColor = UIColor.clear.cgColor
    }
    
    //Функция отключения кнопок(антиспам)
    private func toggleButtons(isEnabled: Bool){
        nobutton.isEnabled = isEnabled
        yesbutton.isEnabled = isEnabled
    }
    
    //Конвертация вопроса для отображения
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(), question: model.text, questionNumber: questionNumber)
    }
    
    //Функция отображения текущего вопроса
    private func show(quiz step: QuizStepViewModel){
        if previewImage.isHidden {
            previewImage.isHidden = false
        }
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
    }
    
    //Функция для начала новой игры
    private func newGame(){
        currentQuestionIndex = 0
        correctAnswer = 0
        questionFactory?.requestNextQuestion()
        previewImage.layer.borderColor = UIColor.clear.cgColor
    }
    
    //Функция генерации сообщения статистики
    private func makeStatisticMessage(statistic: StatisticServiceProtocol?, current gameMessage: String) -> String{
        guard let gamesCount = statistic?.gamesCount else {return gameMessage}
        guard let correctAnswers = statistic?.bestGame.correct else {return gameMessage}
        guard let questionCount = statistic?.bestGame.total else {return gameMessage}
        guard let date = statistic?.bestGame.date else {return gameMessage}
        guard let accuracy = statistic?.totalAccuracy else {return gameMessage}
        let statMessage = """
           \(gameMessage)
           Количество сыграных квизов: \(gamesCount)
           Рекород: \(correctAnswers)/\(questionCount) (\(date.dateTimeString))
           Средняя точность: \(String(format: "%.2f", accuracy))%
           """
        return statMessage
    }
    
    //Функция отображения алерта об окончании квиза
    private func show(quiz result: QuizResultViewModel){
        statisticService?.store(correct: correctAnswer, total: questionsAmount)
        let message = makeStatisticMessage(statistic: statisticService, current: result.text)
        let alert = AlertModel(title: result.title, message: message, buttonText: result.buttonText, completion: {[weak self] in
            guard let self = self else { return }
            self.newGame()
        })
        AlertPresenter.alertPresten(vc: self, alertModel: alert)
    }
    
    //Функция покраски рамки изображения после ответа
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswer += 1
            previewImage.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            previewImage.layer.borderColor = UIColor.ypRed.cgColor
        }
        toggleButtons(isEnabled: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){[weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
            self.toggleButtons(isEnabled: true)
        }
    }
    
    //Функция отображения результата ответа
    private func showNextQuestionOrResult(){
        if currentQuestionIndex == questionsAmount - 1 {
            let result = QuizResultViewModel(title: "Этот раунд окончен", text: "Ваш результат: \(correctAnswer)/\(questionsAmount)", buttonText: "Сыграть ещё раз")
            show(quiz: result)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            previewImage.layer.borderColor = UIColor.clear.cgColor
        }
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
