import Foundation

struct Book: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var author: String
    var isbn: String
    var dateAdded: Date

    init(id: UUID = UUID(), title: String, author: String, isbn: String = "", dateAdded: Date = Date()) {
        self.id = id
        self.title = title
        self.author = author
        self.isbn = isbn
        self.dateAdded = dateAdded
    }
}
