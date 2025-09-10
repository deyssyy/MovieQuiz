import Foundation

struct MostPopularMovies: Codable{
    let items: [MostPopularMovie]
    let errorMessage: String
    
    private enum CodingKeys: String, CodingKey {
        case items, errorMessage
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decode([MostPopularMovie].self, forKey: .items)
        self.errorMessage = try container.decode(String.self, forKey: .errorMessage)
    }
}
