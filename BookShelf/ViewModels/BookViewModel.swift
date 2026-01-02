import Foundation

@MainActor
class BookViewModel: ObservableObject {
    @Published private(set) var books: [Book] = []

    private let storageKey = "bookshelf_books"

    init() {
        loadBooks()
    }

    func addBook(_ book: Book) {
        books.append(book)
        books.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        saveBooks()
    }

    func deleteBook(_ book: Book) {
        books.removeAll { $0.id == book.id }
        saveBooks()
    }

    func findDuplicate(title: String, author: String, isbn: String?) -> Book? {
        if let isbn = isbn, !isbn.isEmpty {
            if let match = books.first(where: { $0.isbn?.lowercased() == isbn.lowercased() }) {
                return match
            }
        }

        return books.first { book in
            book.title.lowercased() == title.lowercased() &&
            book.author.lowercased() == author.lowercased()
        }
    }

    private func saveBooks() {
        if let encoded = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func loadBooks() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Book].self, from: data) {
            books = decoded
        }
    }
}
