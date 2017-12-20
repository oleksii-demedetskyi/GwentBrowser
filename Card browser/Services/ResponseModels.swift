import Foundation

struct CardsResponse: Codable {
    let next: URL?
    let results: [CardLink]
}

struct CardLink: Codable {
    let href: URL
    let name: String
}

struct Card: Codable {
    let name: String
    let flavor: String
    let strength: Int?
    let info: String?
}
