/// This is peruly marker protocol,
/// it allows us to keep action list open, and add more actions
/// without breaking existed components.
///
/// Also sometimes it is nice to implement `Codable` or `Equatable`
protocol Action {}
