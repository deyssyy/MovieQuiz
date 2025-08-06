import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var QuestionLabel: UILabel!
    @IBOutlet private weak var PreviewImage: UIImageView!
    @IBOutlet private weak var IndexLabel: UILabel!
    @IBOutlet private weak var Nobutton: UIButton!
    @IBOutlet private weak var Yesbutton: UIButton!
    @IBOutlet private weak var QuestionTitleLabel: UILabel!
    
    private struct QuizStepViewModel {
      let image: UIImage
      let question: String
      let questionNumber: String
    }
    
    private struct QuizResultViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    private struct QuizQuestion{
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    private var currentQuestionIndex = 0
    private var correctAnswer = 0
    
    //массив вопросов
    private let questions: [QuizQuestion] = [QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)]
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFont()
        let currentQuiestion = questions[currentQuestionIndex]
        let viewModel = convert(model: currentQuiestion)
        show(quiz: viewModel)
    }
    
    //Нажатие на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: Any) {
        let answer = true
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    //Нажатие на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: Any) {
        let answer = false
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    //Функция для установки шрифтов
    private func setupFont(){
        IndexLabel.font = UIFont(name: "YSDispaly-medium", size: 20)
        QuestionLabel.font = UIFont(name: "YSDisplay-bold", size: 23)
        Yesbutton.titleLabel?.font = UIFont(name: "YSDispaly-medium", size: 20)
        Nobutton.titleLabel?.font = UIFont(name: "YSDispaly-medium", size: 20)
        QuestionTitleLabel.font = UIFont(name: "YSDispaly-medium", size: 20)
    }
    
    //Функция отключения кнопок(антиспам)
    private func toggleButtons(isEnabled: Bool){
        Nobutton.isEnabled = isEnabled
        Yesbutton.isEnabled = isEnabled
    }
    
    //Конвертация вопроса для отображения
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionNumber = "\(currentQuestionIndex + 1)/\(questions.count)"
        return QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(), question: model.text, questionNumber: questionNumber)
    }
    
    
    //Функция отображения текущего вопроса
    private func show(quiz step: QuizStepViewModel){
        PreviewImage.image = step.image
        QuestionLabel.text = step.question
        IndexLabel.text = step.questionNumber
    }
    
    //Функция отображения алерта об окончании квиза
    private func show(quiz result: QuizResultViewModel){
        let alert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default){_ in
            self.currentQuestionIndex = 0
            self.correctAnswer = 0
            let currentQuiestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: currentQuiestion)
            self.show(quiz: viewModel)
            self.PreviewImage.layer.borderColor = UIColor.clear.cgColor
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //Функция покраски рамки изображения после ответа
    private func showAnswerResult(isCorrect: Bool) {
        PreviewImage.layer.masksToBounds = true
        PreviewImage.layer.borderWidth = 8
        PreviewImage.layer.cornerRadius = 20
        if isCorrect{
            correctAnswer += 1
            PreviewImage.layer.borderColor = UIColor.ypGreen.cgColor
        }else{
            PreviewImage.layer.borderColor = UIColor.ypRed.cgColor
        }
        toggleButtons(isEnabled: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            self.showNextQuestionOrResult()
            self.toggleButtons(isEnabled: true)
        }
    }
    
    //Функция отображения результата ответа
    private func showNextQuestionOrResult(){
        if currentQuestionIndex == questions.count - 1{
            let result = QuizResultViewModel(title: "Этот раунд окончен", text: "Ваш результат: \(correctAnswer)/\(questions.count)", buttonText: "Сыграть ещё раз")
            show(quiz: result)
        }else{
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            PreviewImage.layer.borderColor = UIColor.clear.cgColor
            show(quiz: viewModel)
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
