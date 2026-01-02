import Foundation

@Observable
class BookViewModel {
    private let storageKey = "savedBooks"

    var books: [Book] = []
    var searchText: String = ""

    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return books.sorted { $0.dateAdded > $1.dateAdded }
        }
        return books.filter { book in
            book.title.localizedCaseInsensitiveContains(searchText) ||
            book.author.localizedCaseInsensitiveContains(searchText) ||
            book.isbn.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.dateAdded > $1.dateAdded }
    }

    init() {
        loadBooks()
    }

    func addBook(title: String, author: String, isbn: String) {
        let book = Book(title: title, author: author, isbn: isbn)
        books.append(book)
        saveBooks()
    }

    func deleteBook(_ book: Book) {
        books.removeAll { $0.id == book.id }
        saveBooks()
    }

    func deleteBooks(at offsets: IndexSet) {
        let booksToDelete = offsets.map { filteredBooks[$0] }
        for book in booksToDelete {
            books.removeAll { $0.id == book.id }
        }
        saveBooks()
    }

    func isDuplicate(title: String, author: String) -> Bool {
        books.contains { book in
            book.title.localizedCaseInsensitiveCompare(title) == .orderedSame &&
            book.author.localizedCaseInsensitiveCompare(author) == .orderedSame
        }
    }

    func isbnExists(_ isbn: String) -> Bool {
        guard !isbn.isEmpty else { return false }
        return books.contains { $0.isbn == isbn }
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
