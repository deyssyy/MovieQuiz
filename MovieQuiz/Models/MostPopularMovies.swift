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

struct MostPopularMovie: Codable{
    let title: String
    let rating: String
    let imageURL: URL
    
    var resizedImageUrl: URL {
        let urlString = imageURL.absoluteString
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        guard let newUrl = URL(string: imageUrlString) else {
            return imageURL
        }
        return newUrl
    }
    
    enum ParsingError: Error {
        case invalidURL
    }
   
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try container.decode(String.self, forKey: .title)
        self.rating = try container.decode(String.self, forKey: .rating)
        
        let imageURL = try container.decode(String.self, forKey: .imageURL)
        guard let url = URL(string: imageURL) else { throw ParsingError.invalidURL }
        self.imageURL = url
    }
}
