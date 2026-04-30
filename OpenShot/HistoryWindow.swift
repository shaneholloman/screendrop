//
//  HistoryWindow.swift
//  OpenShot
//
//  Created by Codex on 01/05/26.
//

import AppKit
import SwiftUI

struct HistoryWindow: View {
    @State private var historyStore = ScreenshotHistoryStore.shared
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            if historyStore.items.isEmpty {
                ContentUnavailableView(
                    "No Screenshots",
                    systemImage: "photo.stack",
                    description: Text("Captured screenshots will appear here.")
                )
                .frame(minWidth: 640, minHeight: 380)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(historyStore.items) { item in
                            HistoryItemRow(item: item) {
                                openWindow(id: "ANNOTATION_EDITOR", value: item.url)
                            }

                            if item.id != historyStore.items.last?.id {
                                Divider()
                                    .padding(.leading, 92)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(minWidth: 720, minHeight: 460)
            }
        }
        .onAppear {
            historyStore.reload()
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 26))
                .foregroundStyle(.blue)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text("History")
                    .font(.title3.weight(.semibold))
                Text("\(historyStore.items.count) recent screenshots")
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(20)
    }
}

private struct HistoryItemRow: View {
    let item: ScreenshotHistoryItem
    let onAnnotate: () -> Void

    @State private var thumbnail: NSImage?

    var body: some View {
        HStack(spacing: 14) {
            Group {
                if let thumbnail {
                    Image(nsImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(.quaternary)
                }
            }
            .frame(width: 64, height: 48)
            .clipShape(.rect(cornerRadius: 6))
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(.separator.opacity(0.45), lineWidth: 1)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.fileName)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.middle)

                Text("\(item.createdAt.formatted(date: .abbreviated, time: .shortened)) - \(item.pixelWidth)x\(item.pixelHeight)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Spacer(minLength: 16)

            HStack(spacing: 8) {
                Button {
                    try? ScreenshotFileActions.copyPNGToClipboard(from: item.url)
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .help("Copy")

                Button(action: onAnnotate) {
                    Image(systemName: "pencil")
                }
                .help("Annotate")

                Button {
                    ScreenshotHistoryStore.shared.reveal(item)
                } label: {
                    Image(systemName: "finder")
                }
                .help("Reveal in Finder")

                Button(role: .destructive) {
                    ScreenshotHistoryStore.shared.delete(item)
                } label: {
                    Image(systemName: "trash")
                }
                .help("Delete")
            }
            .buttonStyle(.borderless)
            .controlSize(.large)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .task(id: item.fileName) {
            thumbnail = ScreenshotImageLoader.downsampledImage(at: item.url, maxPixelSize: 160)
        }
    }
}
