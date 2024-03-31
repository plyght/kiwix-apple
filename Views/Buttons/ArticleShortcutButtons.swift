/*
 * This file is part of Kiwix for iOS & macOS.
 *
 * Kiwix is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * any later version.
 *
 * Kiwix is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Kiwix; If not, see https://www.gnu.org/licenses/.
*/

//
//  ArticleShortcutButtons.swift
//  Kiwix
//
//  Created by Chris Li on 9/3/23.
//  Copyright © 2023 Chris Li. All rights reserved.
//

import SwiftUI

struct ArticleShortcutButtons: View {
    @Environment(\.dismissSearch) private var dismissSearch
    @EnvironmentObject private var browser: BrowserViewModel
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ZimFile.size, ascending: false)],
        predicate: ZimFile.openedPredicate
    ) private var zimFiles: FetchedResults<ZimFile>
    
    let displayMode: DisplayMode

    enum DisplayMode {
        case mainArticle, randomArticle, mainAndRandomArticle
    }
    
    var body: some View {
        switch displayMode {
        case .mainArticle:
            mainArticle
        case .randomArticle:
            randomArticle
        case .mainAndRandomArticle:
            mainArticle
            randomArticle
        }
    }
    
    private var mainArticle: some View {
        #if os(macOS)
        Button {
            browser.loadMainArticle()
            dismissSearch()
        } label: {
            Label("article_shortcut.main.button.title".localized, systemImage: "house")
        }
        .disabled(zimFiles.isEmpty)
        .help("article_shortcut.main.button.help".localized)
        #elseif os(iOS)
        Menu {
            ForEach(zimFiles) { zimFile in
                Button(zimFile.name) {
                    browser.loadMainArticle(zimFileID: zimFile.fileID)
                    dismissSearch()
                }
            }
        } label: {
            Label("article_shortcut.main.button.title".localized, systemImage: "house")
        } primaryAction: {
            browser.loadMainArticle()
            dismissSearch()
        }
        .disabled(zimFiles.isEmpty)
        .help("article_shortcut.main.button.help".localized)
        #endif
    }
    
    var randomArticle: some View {
        #if os(macOS)
        Button {
            browser.loadRandomArticle()
            dismissSearch()
        } label: {
            Label("article_shortcut.random.button.title.mac".localized, systemImage: "die.face.5")
        }
        .disabled(zimFiles.isEmpty)
        .help("article_shortcut.random.button.help".localized)
        .keyboardShortcut(KeyEquivalent("r"), modifiers: [.command, .option])

        #elseif os(iOS)
        Menu {
            ForEach(zimFiles) { zimFile in
                Button(zimFile.name) {
                    browser.loadRandomArticle(zimFileID: zimFile.fileID)
                    dismissSearch()
                }
            }
        } label: {
            Label("article_shortcut.random.button.title.ios".localized, systemImage: "die.face.5")
        } primaryAction: {
            browser.loadRandomArticle()
            dismissSearch()
        }
        .disabled(zimFiles.isEmpty)
        .help("article_shortcut.random.button.help".localized)
        #endif
    }
}
