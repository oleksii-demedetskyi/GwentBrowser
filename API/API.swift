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
