import Foundation

public class GwentAPI {
    public let session: URLSession
    public let schema: Future<Result<Response.Schema>>
    
    public init(url: URL = URL(string: "https://api.gwentapi.com/v0/")!,
                session: URLSession = URLSession.shared)
    {
        self.session = session
        schema = session.dataFuture(with: url)
            .map(Parse.ok)
            .map(Parse.json)
            .map(Parse.object)
            .map(Parse.schema)
    }
    
    func getJSON(url: URL) -> Future<Result<[String: Any]>> {
        return session.dataFuture(with: url)
            .map(Parse.ok)
            .map(Parse.json)
            .map(Parse.object)
    }
    
    public func getCards(url: URL?) -> Future<Result<Response.Cards>> {
        return  schema.map { url ?? $0.cards }
            .then(getJSON)
            .map(Parse.cards)
    }
    
    public func getCard(link: Response.CardLink) -> Future<Result<Response.Card>> {
        return getJSON(url: link.href).map(Parse.card)
    }
}

extension GwentAPI {
    public enum Response {
        public struct Schema {
            public let cards: URL
            public let categories: URL
            public let factions: URL
            public let groups: URL
            public let rarities: URL
            public let swagger: URL
            public let version: String
        }
        
        public struct CategoryLink {
            public let href: URL
            public let name: String
        }
        
        public struct FactionLink {
            public let href: URL
            public let name: String
        }
        
        public struct GroupLink {
            public let href: URL
            public let name: String
        }
        
        public struct VariationLink {
            public let availability: String
            public let href: URL
            public let rarity: RarityLink
        }
        
        public struct RarityLink {
            public let href: URL
            public let name: String
        }
        
        public struct Card {
            public let categories: [CategoryLink]
            public let faction: FactionLink
            public let flavor: String
            public let group: GroupLink
            public let href: URL
            public let info: String
            public let name: String
            public let positions: [String]
            public let strength: Int?
            public let uuid: String
            public let variations: [VariationLink]
        }
        
        public struct Cards {
            public let count: Int
            public let previous: URL?
            public let next: URL?
            public let results: [CardLink]
            
            public init(count: Int, previous: URL?, next: URL?, results: [CardLink]) {
                self.count = count
                self.previous = previous
                self.next = next
                self.results = results
            }
        }
        
        public struct CardLink {
            public let href: URL
            public let name: String
            
            public init(href: URL, name: String) {
                self.href = href
                self.name = name
            }
        }
    }
}

extension GwentAPI {
    enum Parse {
        enum Error: Swift.Error {
            case networking(Swift.Error)
            case noResponse
            case notHTTP(URLResponse)
            case not200(HTTPURLResponse)
            case noData(HTTPURLResponse)
            case notJSON(Data, Swift.Error)
            case notAnObject(Any)
            case notAnArray(Any)
            case notAString(Any)
            case notAnInt(Any)
            case notAnURL(String)
            case missedKey(String)
            case badSchema([String: Any], Swift.Error)
            case badCards([String: Any], Swift.Error)
            case badCardLink([String: Any], Swift.Error)
            case badCard([String: Any], Swift.Error)
            case badGroupLink([String: Any], Swift.Error)
            case badCategoryLink([String: Any], Swift.Error)
            case badFactionLink([String: Any], Swift.Error)
            case badVariationLink([String: Any], Swift.Error)
            case badRarityLink([String: Any], Swift.Error)
        }
        
        static func ok(data: Data?, response: URLResponse?, error: Swift.Error?) throws -> Data {
            if let error = error { throw Error.networking(error) }
            guard let response = response else { throw Error.noResponse }
            guard let httpResponse = response as? HTTPURLResponse else { throw Error.notHTTP(response) }
            guard httpResponse.statusCode == 200 else { throw Error.not200(httpResponse) }
            guard let data = data else { throw Error.noData(httpResponse) }
            
            return data
        }
        
        static func json(from data: Data) throws -> Any {
            do { return try JSONSerialization.jsonObject(with: data) }
            catch { throw Error.notJSON(data, error) }
        }
        
        static func object(from any: Any) throws -> [String: Any] {
            guard let object = any as? [String: Any] else { throw Error.notAnObject(any)}
            return object
        }
        
        static func array(from any: Any) throws -> [Any] {
            guard let array = any as? [Any] else { throw Error.notAnArray(any) }
            return array
        }
        
        static func string(from any: Any) throws -> String {
            guard let string = any as? String  else { throw Error.notAString(any)}
            return string
        }
        
        static func int(from any: Any) throws -> Int {
            guard let int = any as? Int else { throw Error.notAnInt(any) }
            return int
        }
        
        static func url(from string: String) throws -> URL {
            guard let url = URL(string: string) else { throw Error.notAnURL(string) }
            return url
        }
        
        static func key(_ string: String, from object: [String: Any]) throws -> Any {
            guard let value = object[string] else { throw Error.missedKey(string) }
            return value
        }
        
        static func schema(json: [String: Any]) throws -> Response.Schema {
            do { return try Response.Schema(
                cards: url(from: string(from: key("cards", from: json))),
                categories: url(from: string(from: key("categories", from: json))),
                factions: url(from: string(from: key("factions", from: json))),
                groups: url(from: string(from: key("groups", from: json))),
                rarities: url(from: string(from: key("rarities", from: json))),
                swagger: url(from: string(from: key("swagger", from: json))),
                version: string(from: key("version", from: json))) }
            catch { throw Error.badSchema(json, error) }
        }
        
        static func cards(json: [String: Any]) throws -> Response.Cards {
            do { return try Response.Cards(
                count: int(from: key("count", from: json)),
                previous: try? url(from: string(from: key("previous", from: json))),
                next: try? url(from: string(from: key("next", from: json))),
                results: array(from: key("results", from: json)).map {
                    try cardLink(from: object(from: $0))})}
            catch { throw Error.badCards(json, error) }
        }
        
        static func cardLink(from json: [String: Any]) throws -> Response.CardLink {
            do { return try Response.CardLink(
                href: url(from: string(from: key("href", from: json))),
                name: string(from: key("name", from: json)))}
            catch { throw Error.badCardLink(json, error) }
        }
        
        static func card(from json: [String: Any]) throws -> Response.Card {
            do { return try Response.Card(
                categories: array(from: key("categories", from: json)).map {
                    try categoryLink(from: object(from: $0)) },
                faction: factionLink(from: object(from: key("faction", from: json))),
                flavor: string(from: key("flavor", from: json)),
                group: groupLink(from: object(from: key("group", from: json))),
                href: url(from: string(from: key("href", from: json))),
                info: string(from: key("info", from: json)),
                name: string(from: key("name", from: json)),
                positions: array(from: key("positions", from: json)).map(string),
                strength: try? int(from: key("strength", from: json)),
                uuid: string(from: key("uuid", from: json)),
                variations: array(from: key("variations", from: json)).map {
                    try variationLink(from: object(from: $0)) })}
            catch { throw Error.badCard(json, error) }
        }
        
        static func groupLink(from json: [String: Any]) throws -> Response.GroupLink {
            do { return try Response.GroupLink(
                href: url(from: string(from: key("href", from: json))),
                name: string(from: key("name", from: json))) }
            catch { throw Error.badGroupLink(json, error) }
        }
        
        static func categoryLink(from json: [String: Any]) throws -> Response.CategoryLink {
            do { return try Response.CategoryLink(
                href: url(from: string(from: key("href", from: json))),
                name: string(from: key("name", from: json))) }
            catch { throw Error.badCategoryLink(json, error) }
        }
        
        static func factionLink(from json: [String: Any]) throws -> Response.FactionLink {
            do { return try Response.FactionLink(
                href: url(from: string(from: key("href", from: json))),
                name: string(from: key("name", from: json))) }
            catch { throw Error.badFactionLink(json, error) }
        }
        
        static func variationLink(from json: [String: Any]) throws -> Response.VariationLink {
            do { return try Response.VariationLink(
                availability: string(from: key("availability", from: json)),
                href: url(from: string(from: key("href", from: json))),
                rarity: rarityLink(from: object(from: key("rarity", from: json)))) }
            catch { throw Error.badVariationLink(json, error) }
        }
        
        static func rarityLink(from json: [String: Any]) throws -> Response.RarityLink {
            do { return try Response.RarityLink(
                href: url(from: string(from: key("href", from: json))),
                name: string(from: key("name", from: json))) }
            catch { throw Error.badRarityLink(json, error) }
        }
    }
}
