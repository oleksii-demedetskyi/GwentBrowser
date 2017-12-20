/// This is simple apply like function.
/// It main goal to avoid code like this:
///
/// ```
/// let x = { ... }()
/// ```
///
/// Instead you can write:
/// ```
/// let x = result { ... }
/// ```
func result<Result>(from block: () -> Result) -> Result {
    return block()
}
