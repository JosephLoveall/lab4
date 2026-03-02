//
//  ContentView.swift
//  lab4
//
//  Created by Joseph Loveall (Student) on 3/2/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = BookListViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let book = vm.currentBook {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Title: \(book.title)")
                        Text("Author: \(book.author)")
                        Text("Genre: \(book.genre)")
                        Text(String(format: "Price: $%.2f", book.price))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                } else {
                    Text("No books available.")
                        .foregroundStyle(.secondary)
                        .padding()
                }

                Spacer()
            }
            .navigationTitle("Booklist")
        }
    }
}
#Preview {
    ContentView()
}
