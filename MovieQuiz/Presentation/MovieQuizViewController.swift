import UIKit

final class MovieQuizViewController: UIViewController {

    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var nobutton: UIButton!
    @IBOutlet private weak var yesbutton: UIButton!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var statisticService: StatisticServiceProtocol?
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFont()
        setupImageView()
        showLoadingIndicator()
        presenter = MovieQuizPresenter(viewController: self)
        statisticService = StatisticService()
    }
    
    // MARK: - QuestionFactoryDelegate

   
    
    //Нажатие на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    //Нажатие на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    //Функция отвечающая за показ и старт анимации у индикатора загрузки
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    //Функция отвечающая за скрытие и остановку анимации у индикатора загрузки
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    
    //Функция отвечающая за создание алерта при неудачной загрузке из сети
    func showNetworkError(message: String){
        hideLoadingIndicator()
        let title = "Ошибка"
        let buttonText = "Попробовать ещё раз"
        let alert = AlertModel(title: title,
                           message: message,
                           buttonText: buttonText) {[weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
            
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
    
    //Функция отображения текущего вопроса
    func show(quiz step: QuizStepViewModel){
        if previewImage.isHidden {
            previewImage.isHidden = false
        }
        previewImage.layer.borderColor = UIColor.clear.cgColor
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
    }
    
//    //Функция для начала новой игры
//    private func newGame(){
//        presenter.restartGame()
//        previewImage.layer.borderColor = UIColor.clear.cgColor
//    }
//    
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
    func show(quiz result: QuizResultViewModel){
        statisticService?.store(correct: presenter.correctAnswer, total: presenter.questionsAmount)
        let message = makeStatisticMessage(statistic: statisticService, current: result.text)
        let alert = AlertModel(title: result.title, message: message, buttonText: result.buttonText, completion: {[weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
        })
        AlertPresenter.alertPresten(vc: self, alertModel: alert)
    }
    
    //Функция покраски рамки изображения после ответа
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        if isCorrect {
            previewImage.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            previewImage.layer.borderColor = UIColor.ypRed.cgColor
        }
        toggleButtons(isEnabled: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){[weak self] in
            guard let self = self else { return }
            self.presenter.showNextQuestionOrResult()
            self.toggleButtons(isEnabled: true)
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
