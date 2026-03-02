//
//  BookListViewModel.swift
//  lab4
//
//  Created by Joseph Loveall (Student) on 3/2/26.
//

import Foundation

class BookListViewModel: ObservableObject {

    @Published private(set) var books: [Book] = [
        Book(title: "Dune", author: "Joe Love", genre: "Sci-fi", price: 67.69),
        Book(title: "The Hobbit", author: "Joe Love", genre: "Fantasy", price: 7.49),
        Book(title: "Atomic Habits", author: "Also Joe Love", genre: "Nonfiction", price: 11.99)
    ]
    
    @Published var currentIndex: Int = 0

    var currentBook: Book? {
        guard books.indices.contains(currentIndex) else { return nil }
        return books[currentIndex]
    }

    // MARK: - Navigation (Next/Prev)
    func moveNext() -> Bool {
        guard currentIndex < books.count - 1 else { return false }
        currentIndex += 1
        return true
    }

    func movePrev() -> Bool {
        guard currentIndex > 0 else { return false }
        currentIndex -= 1
        return true
    }

    // MARK: - Stubs for later chunks
    func addBook(_ book: Book) {
        books.append(book)
        currentIndex = max(books.count - 1, 0)
    }

    func deleteBook(withTitle title: String) -> Bool {
        // stub behavior
        return false
    }

    func search(query: String) -> Int? {
        // stub behavior
        return nil
    }

    func updateBook(at index: Int, newValue: Book) -> Bool {
        // stub behavior
        return false
    }
}
