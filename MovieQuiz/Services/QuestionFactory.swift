import Foundation
final class QuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    
    init(delegate: QuestionFactoryDelegate?, moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    func loadData(){
        moviesLoader.loadMovie{[weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
               
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                
                case .failure(let error):
                    self.delegate?.didFailToLoadDataFromServer(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global(qos: .utility).async{[weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = movies[safe: index] else { return }
            
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.resizedImageUrl)
            }
            catch {
                print("Faild to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            let targetRating = Int.random(in: 1...9)
            var text = ""
            var correctAnswer: Bool = false
            let questionCase = Int.random(in: 0...1)
            switch questionCase{
                case 0:  
                text = "Рейтинг этого фильма больше чем \(targetRating)?"
                correctAnswer = rating > Float(targetRating)
            default:
                text = "Рейтинг этого фильма меньше чем \(targetRating)?"
                correctAnswer = rating < Float(targetRating)
            }
            
            let question = QuizQuestion(image: imageData,
                                    text: text,
                                    correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
