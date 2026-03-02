import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var vm = BookListViewModel()

    private enum ActiveSheet: Identifiable {
        case search, add, delete
        var id: Int { hashValue }
    }

    @State private var activeSheet: ActiveSheet?
    @State private var showOops = false
    @State private var oopsMessage = ""

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                bookCard
                Spacer()
            }
            .navigationTitle("BookList")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button { activeSheet = .search } label: { Image(systemName: "magnifyingglass") }
                    Button { activeSheet = .add } label: { Image(systemName: "plus") }
                }

                ToolbarItem(placement: .bottomBar) {
                    Button { activeSheet = .delete } label: { Image(systemName: "trash") }
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()

                    Button("Previous") {
                        if !vm.prev() {
                            oopsMessage = "No previous book available."
                            showOops = true
                        }
                    }

                    Spacer()

                    Button("Next") {
                        if !vm.next() {
                            oopsMessage = "No next book available."
                            showOops = true
                        }
                    }

                    Spacer()
                }
            }
            .alert("Oops...", isPresented: $showOops) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(oopsMessage)
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .search: SearchSheet(vm: vm)
                case .add: AddSheet(vm: vm)
                case .delete: DeleteSheet(vm: vm)
                }
            }
        }
    }

    @ViewBuilder
    private var bookCard: some View {
        if let book = vm.currentBook {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue.opacity(0.65))
                    .frame(height: 650)
                    .padding(.horizontal)

                VStack(spacing: 8) {
                    Text("Title: \(book.title)")
                    Text("Author: \(book.author)")
                    Text("Genre: \(book.genre)")
                    Text(String(format: "Price: %.2f", book.price))
                }
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            }
        } else {
            VStack {
                Text("Preview Unavailable")
                Text("Please add your first book")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
struct SearchSheet: View {
    @ObservedObject var vm: BookListViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var results: [Int] = []

    @State private var editTitle = ""
    @State private var editAuthor = ""
    @State private var editGenre = ""
    @State private var editPrice = ""

    @State private var showMessage = false
    @State private var message = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Search Book") {
                    TextField("Enter Title or Genre", text: $query)

                    Button("Search") {
                        results = vm.searchMatches(query: query)
                        if results.isEmpty {
                            message = "No record found."
                            showMessage = true
                        }
                    }
                }

                Section("Results") {
                    if results.isEmpty {
                        Text("No results").foregroundStyle(.secondary)
                    } else {
                        ForEach(results, id: \.self) { index in
                            Button {
                                vm.selectResult(at: index)

                                if let b = vm.book(at: index) {
                                    editTitle = b.title
                                    editAuthor = b.author
                                    editGenre = b.genre
                                    editPrice = String(format: "%.2f", b.price)
                                }

                                message = "Selected."
                                showMessage = true
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(vm.book(at: index)?.title ?? "")
                                    Text(vm.book(at: index)?.genre ?? "")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                Section("Update Book") {
                    TextField("Title", text: $editTitle)
                    TextField("Author", text: $editAuthor)
                    TextField("Genre", text: $editGenre)
                    TextField("Price", text: $editPrice)
                        .keyboardType(.decimalPad)

                    Button("Save Update") {
                        guard let p = Double(editPrice) else {
                            message = "Price must be a number (example: 9.99)."
                            showMessage = true
                            return
                        }

                        let ok = vm.editSelectedResult(
                            title: editTitle,
                            author: editAuthor,
                            genre: editGenre,
                            price: p
                        )

                        message = ok ? "Book updated." : "Select a record from Results first."
                        showMessage = true
                    }
                }
            }
            .navigationTitle("Search Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Message", isPresented: $showMessage) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(message)
            }
        }
    }
}

struct DeleteSheet: View {
    @ObservedObject var vm: BookListViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var titleToDelete = ""
    @State private var showMessage = false
    @State private var message = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Enter Title to Delete", text: $titleToDelete)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                Button("Delete") {
                    let ok = vm.deleteRec(title: titleToDelete)
                    message = ok ? "Deleted." : "No matching book found."
                    showMessage = true
                }

                Spacer()
            }
            .navigationTitle("Delete Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Message", isPresented: $showMessage) {
                Button("OK") { dismiss() }
            } message: {
                Text(message)
            }
        }
    }
}

struct AddSheet: View {
    @ObservedObject var vm: BookListViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var author = ""
    @State private var genre = ""
    @State private var price = ""

    @State private var showMessage = false
    @State private var message = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Add Book") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("Genre", text: $genre)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)

                    Button("Add") {
                        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !t.isEmpty else {
                            message = "Title is required."
                            showMessage = true
                            return
                        }
                        guard let p = Double(price) else {
                            message = "Price must be a number."
                            showMessage = true
                            return
                        }

                        vm.add(t, author, genre, p)
                        message = "Book added."
                        showMessage = true
                    }
                }
            }
            .navigationTitle("Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Message", isPresented: $showMessage) {
                Button("OK") { dismiss() }
            } message: {
                Text(message)
            }
        }
    }
}
#Preview {
    ContentView()
}
