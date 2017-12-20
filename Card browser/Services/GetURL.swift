import Foundation

/// Simple system wrapper.
/// I need this basically for testability reasons only
func getURL<T: Decodable>(url: URL) -> Future<T> {
    return Future { complete in
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            let value = try! JSONDecoder().decode(T.self, from: data!)
            complete(value)
        }
        
        task.resume()
    }
}
