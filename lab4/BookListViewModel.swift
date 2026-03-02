//
//  BookListViewModel.swift
//  lab4
//
//  Created by Joseph Loveall (Student) on 3/2/26.
//

import Foundation

class BookListViewModel: ObservableObject {

    @Published private(set) var books: [Book] = [
           Book(title: "Dune", author: "Frank Herbert", genre: "Sci-Fi", price: 9.99),
           Book(title: "The Hobbit", author: "J.R.R. Tolkien", genre: "Fantasy", price: 7.49),
           Book(title: "Atomic Habits", author: "James Clear", genre: "Nonfiction", price: 11.99)
       ]

       @Published var currentIndex: Int = 0

       // Used to enable "Edit after Search"
       @Published private(set) var lastSearchIndex: Int? = nil

       var currentBook: Book? {
           guard books.indices.contains(currentIndex) else { return nil }
           return books[currentIndex]
       }

       func getCount() -> Int { books.count }

       // MARK: - Add
       func add(_ title: String,
                _ author: String,
                _ genre: String,
                _ price: Double) {
           let b = Book(title: title,
                        author: author,
                        genre: genre,
                        price: price)
           books.append(b)
           currentIndex = max(books.count - 1, 0)
       }

       // MARK: - Delete (by title)
       func deleteRec(title: String) -> Bool {
           let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
           guard !t.isEmpty else { return false }

           guard let idx = books.firstIndex(where: { $0.title.caseInsensitiveCompare(t) == .orderedSame }) else {
               return false
           }

           books.remove(at: idx)

           if books.isEmpty {
               currentIndex = 0
           } else if currentIndex >= books.count {
               currentIndex = books.count - 1
           }

           // If you deleted the last searched record, clear it
           if lastSearchIndex == idx { lastSearchIndex = nil }
           else if let s = lastSearchIndex, idx < s { lastSearchIndex = s - 1 }

           return true
       }

       // MARK: - Search (title OR genre)
       func search(query: String) -> Book? {
           let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
           guard !q.isEmpty else { lastSearchIndex = nil; return nil }

           if let idx = books.firstIndex(where: { $0.title.localizedCaseInsensitiveContains(q) }) {
               lastSearchIndex = idx
               return books[idx]
           }

           if let idx = books.firstIndex(where: { $0.genre.localizedCaseInsensitiveContains(q) }) {
               lastSearchIndex = idx
               return books[idx]
           }

           lastSearchIndex = nil
           return nil
       }

       // MARK: - Edit (only after search)
       func editLastSearched(title: String, author: String, genre: String, price: Double) -> Bool {
           guard let idx = lastSearchIndex, books.indices.contains(idx) else { return false }
           books[idx].title = title
           books[idx].author = author
           books[idx].genre = genre
           books[idx].price = price
           currentIndex = idx
           return true
       }

       // MARK: - Next/Prev
       func next() -> Bool {
           guard currentIndex < books.count - 1 else { return false }
           currentIndex += 1
           return true
       }

       func prev() -> Bool {
           guard currentIndex > 0 else { return false }
           currentIndex -= 1
           return true
       }
    
    func book(at index: Int) -> Book? {
        guard books.indices.contains(index) else { return nil }
        return books[index]
    }

    func searchMatches(query: String) -> [Int] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }

        return books.indices.filter { i in
            books[i].title.localizedCaseInsensitiveContains(q) ||
            books[i].genre.localizedCaseInsensitiveContains(q)
        }
    }
    
    func focusResult(index: Int) {
        guard books.indices.contains(index) else { return }
        currentIndex = index
        lastSearchIndex = index
    }
       
   }
