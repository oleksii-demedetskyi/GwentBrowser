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
