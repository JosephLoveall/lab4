//BooklistViewModle
import Foundation

class BookListViewModel: ObservableObject {

    @Published private(set) var books: [Book] = []

    @Published var currentIndex: Int = 0
    private var lastSearchIndex: Int?

    var currentBook: Book? {
        books.indices.contains(currentIndex) ? books[currentIndex] : nil
    }
    
    func add(_ title: String,_ author: String,_ genre: String,_ price: Double) {
        books.append(Book(title: title,
                          author: author,
                          genre: genre,
                          price: price))
        currentIndex = max(books.count - 1, 0)
        lastSearchIndex = nil
    }

    func deleteRec(title: String) -> Bool {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return false }

        guard let idx = books.firstIndex(where:{ $0.title.caseInsensitiveCompare(t) == .orderedSame })
        else {
            return false
        }

        books.remove(at: idx)

        if books.isEmpty {
            currentIndex = 0
        } else if currentIndex >= books.count {
            currentIndex = books.count - 1
        }
        
        if lastSearchIndex == idx { lastSearchIndex = nil }
        else if let s = lastSearchIndex, idx < s { lastSearchIndex = s - 1 }

        return true
    }

    func searchMatches(query: String) -> [Int] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }

        return books.indices.filter { i in
            books[i].title.localizedCaseInsensitiveContains(q) ||
            books[i].genre.localizedCaseInsensitiveContains(q)
        }
    }

    func selectResult(at index: Int) {
        guard books.indices.contains(index) else { return }
        currentIndex = index
        lastSearchIndex = index
    }

    func editSelectedResult(title: String, author: String, genre: String, price: Double) -> Bool {
        guard let idx = lastSearchIndex, books.indices.contains(idx) else { return false }
        books[idx].title = title
        books[idx].author = author
        books[idx].genre = genre
        books[idx].price = price
        currentIndex = idx
        return true
    }

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
        books.indices.contains(index) ? books[index] : nil
    }
}
