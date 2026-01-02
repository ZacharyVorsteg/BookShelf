import SwiftUI

struct ContentView: View {
    @State private var viewModel = BookViewModel()
    @State private var showingAddSheet = false
    @State private var newTitle = ""
    @State private var newAuthor = ""
    @State private var newISBN = ""
    @State private var showDuplicateAlert = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.books.isEmpty {
                    ContentUnavailableView(
                        "No Books Yet",
                        systemImage: "books.vertical",
                        description: Text("Tap + to add your first book")
                    )
                } else {
                    List {
                        ForEach(viewModel.filteredBooks) { book in
                            BookRow(book: book)
                        }
                        .onDelete(perform: viewModel.deleteBooks)
                    }
                    .searchable(text: $viewModel.searchText, prompt: "Search by title, author, or ISBN")
                }
            }
            .navigationTitle("BookShelf")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
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
                AddBookSheet(
                    title: $newTitle,
                    author: $newAuthor,
                    isbn: $newISBN,
                    onSave: addBook,
                    onCancel: resetForm
                )
            }
            .alert("Duplicate Book", isPresented: $showDuplicateAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You already have this book in your collection!")
            }
        }
    }

    private func addBook() {
        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAuthor = newAuthor.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedISBN = newISBN.trimmingCharacters(in: .whitespacesAndNewlines)

        if viewModel.isDuplicate(title: trimmedTitle, author: trimmedAuthor) ||
           viewModel.isbnExists(trimmedISBN) {
            showDuplicateAlert = true
            return
        }

        viewModel.addBook(title: trimmedTitle, author: trimmedAuthor, isbn: trimmedISBN)
        resetForm()
        showingAddSheet = false
    }

    private func resetForm() {
        newTitle = ""
        newAuthor = ""
        newISBN = ""
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
            if !book.isbn.isEmpty {
                Text("ISBN: \(book.isbn)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddBookSheet: View {
    @Binding var title: String
    @Binding var author: String
    @Binding var isbn: String
    let onSave: () -> Void
    let onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Book Details") {
                    TextField("Title", text: $title)
                        .textContentType(.none)
                    TextField("Author", text: $author)
                        .textContentType(.name)
                    TextField("ISBN (optional)", text: $isbn)
                        .textContentType(.none)
                        .keyboardType(.numberPad)
                }

                Section {
                    Text("Adding a book helps you avoid buying duplicates when browsing at stores.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
