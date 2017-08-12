extension GwentAPI.Response.CardLink: Equatable {
    public static func ==(lhs: GwentAPI.Response.CardLink, rhs: GwentAPI.Response.CardLink) -> Bool {
        return lhs.href == rhs.href && lhs.name == rhs.name
    }
}

extension GwentAPI.Response.Cards: Equatable {
    public static func ==(lhs: GwentAPI.Response.Cards, rhs: GwentAPI.Response.Cards) -> Bool {
        return lhs.count == rhs.count &&
            lhs.next == rhs.next &&
            lhs.previous == rhs.previous &&
            lhs.results == rhs.results
    }
}
