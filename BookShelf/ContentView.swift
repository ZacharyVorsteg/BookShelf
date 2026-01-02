import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BookViewModel()
    @State private var showingAddSheet = false
    @State private var searchText = ""

    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return viewModel.books
        }
        return viewModel.books.filter { book in
            book.title.localizedCaseInsensitiveContains(searchText) ||
            book.author.localizedCaseInsensitiveContains(searchText) ||
            (book.isbn?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.books.isEmpty {
                    ContentUnavailableView(
                        "No Books Yet",
                        systemImage: "books.vertical",
                        description: Text("Tap + to add books to your collection")
                    )
                } else {
                    List {
                        ForEach(filteredBooks) { book in
                            BookRow(book: book)
                        }
                        .onDelete { indexSet in
                            let booksToDelete = indexSet.map { filteredBooks[$0] }
                            for book in booksToDelete {
                                viewModel.deleteBook(book)
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search title, author, or ISBN")
                }
            }
            .navigationTitle("BookShelf")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Text("\(viewModel.books.count) books")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddBookView(viewModel: viewModel)
            }
        }
    }
}

struct BookRow: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(book.title)
                .font(.headline)
            Text(book.author)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let isbn = book.isbn, !isbn.isEmpty {
                Text("ISBN: \(isbn)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddBookView: View {
    @ObservedObject var viewModel: BookViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var author = ""
    @State private var isbn = ""
    @State private var showingDuplicateAlert = false
    @State private var duplicateMessage = ""

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !author.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("ISBN (optional)", text: $isbn)
                }

                Section {
                    Button("Add Book") {
                        addBook()
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Duplicate Found", isPresented: $showingDuplicateAlert) {
                Button("Add Anyway") {
                    saveBook()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(duplicateMessage)
            }
        }
    }

    private func addBook() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedAuthor = author.trimmingCharacters(in: .whitespaces)
        let trimmedISBN = isbn.trimmingCharacters(in: .whitespaces)

        if let duplicate = viewModel.findDuplicate(title: trimmedTitle, author: trimmedAuthor, isbn: trimmedISBN) {
            duplicateMessage = "You already have \"\(duplicate.title)\" by \(duplicate.author) in your collection."
            showingDuplicateAlert = true
        } else {
            saveBook()
        }
    }

    private func saveBook() {
        let book = Book(
            title: title.trimmingCharacters(in: .whitespaces),
            author: author.trimmingCharacters(in: .whitespaces),
            isbn: isbn.trimmingCharacters(in: .whitespaces).isEmpty ? nil : isbn.trimmingCharacters(in: .whitespaces)
        )
        viewModel.addBook(book)
        dismiss()
    }
}

#Preview {
    ContentView()
}
