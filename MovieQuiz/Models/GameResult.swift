import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(previous: GameResult) -> Bool {
        return correct > previous.correct
    }
}
