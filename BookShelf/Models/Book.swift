import Foundation

struct Book: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let author: String
    let isbn: String?
    let dateAdded: Date

    init(id: UUID = UUID(), title: String, author: String, isbn: String? = nil, dateAdded: Date = Date()) {
        self.id = id
        self.title = title
        self.author = author
        self.isbn = isbn
        self.dateAdded = dateAdded
    }
}
