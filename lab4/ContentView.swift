//
//  ContentView.swift
//  lab4
//
//  Created by Joseph Loveall (Student) on 3/2/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = BookListViewModel()
    
    @State private var showSearch = false
    @State private var showDelete = false
    
    @State private var showAdd = false
    @State private var showOops = false
    @State private var oopsMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                if let book = vm.currentBook {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue.opacity(0.65))
                            .frame(height: 350)
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

                Spacer()
            }
            .navigationTitle("BookList")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                //SEARCH
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button { showSearch = true } label: { Image(systemName: "magnifyingglass") }
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }

                //DELETE
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showDelete = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }

                //PREVIOUS/NEXT
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
                }
            }
            .alert("Oops...", isPresented: $showOops) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(oopsMessage)
            }

            //SEARCH SHEET
            .sheet(isPresented: $showSearch) {
                SearchSheet(vm: vm)
            }

            //DELETE SHEET
            .sheet(isPresented: $showDelete) {
                DeleteSheet(vm: vm)
                
            }
            //AADD SHEET
            .sheet(isPresented: $showAdd) {
                AddSheet(vm: vm)
            }
        }
    }
}
struct SearchSheet: View {
    @ObservedObject var vm: BookListViewModel
    @Environment(\.dismiss) var dismiss

    @State private var query = ""
    @State private var results: [Int] = []

    // Edit fields
    @State private var editTitle = ""
    @State private var editAuthor = ""
    @State private var editGenre = ""
    @State private var editPrice = ""
    
    @State private var showAdd = false
    @State private var showMessage = false
    @State private var message = ""

    var body: some View {
        NavigationView {
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
                        Text("No results")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(results, id: \.self) { index in
                            Button {
                                // Focus the selected book (sets currentIndex + lastSearchIndex)
                                vm.focusResult(index: index)

                                // Prefill edit fields from the selected book
                                if let b = vm.book(at: index) {
                                    editTitle = b.title
                                    editAuthor = b.author
                                    editGenre = b.genre
                                    editPrice = String(format: "%.2f", b.price)
                                }

                                message = "Selected: \(vm.book(at: index)?.title ?? "")"
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

                        let ok = vm.editLastSearched(
                            title: editTitle,
                            author: editAuthor,
                            genre: editGenre,
                            price: p
                        )

                        if ok {
                            message = "Book updated."
                            showMessage = true
                        } else {
                            message = "Select a record from Results first."
                            showMessage = true
                        }
                    }
                }
            }
            .navigationTitle("Search Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddSheet(vm: vm)
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
    @Environment(\.dismiss) var dismiss

    @State private var titleToDelete = ""
    @State private var showMessage = false
    @State private var message = ""

    var body: some View {
        NavigationView {
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
                ToolbarItem(placement: .navigationBarLeading) {
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
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var author = ""
    @State private var genre = ""
    @State private var price = ""

    @State private var showMessage = false
    @State private var message = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Add Book") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("Genre", text: $genre)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)

                    Button("Add") {
                        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        if t.isEmpty {
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Message", isPresented: $showMessage) {
                Button("OK") {
                    // after adding, return to main so blue card updates
                    dismiss()
                }
            } message: {
                Text(message)
            }
        }
    }
}
#Preview {
    ContentView()
}
