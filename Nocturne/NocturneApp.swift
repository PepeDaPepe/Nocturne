//
//  NocturneApp.swift
//  Nocturne
//
//  Created by s3 on 30/10/26.
//

import SwiftUI
import SwiftData

@main
struct NocturneApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: SavedMovieEntry.self)
    }
}
