//
//  SettingsGeneralPane.swift
//  Screendrop
//

import AppKit
import SwiftUI

struct GeneralSettingsPane: View {
    @AppStorage(ScreendropPreferences.exportDirectoryPathKey) private var exportDirectoryPath = ""

    var body: some View {
        Form {
            Section("Save Location") {
                LabeledContent("Export folder") {
                    HStack(spacing: 8) {
                        Image(systemName: "folder.fill")
                            .foregroundStyle(.blue)
                            .font(.system(size: 14))

                        Text(ScreendropPreferences.exportDirectory.abbreviatedPath)
                            .font(.system(size: 13))
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundStyle(.primary)
                    }
                }

                HStack(spacing: 8) {
                    Button("Choose Folder...") {
                        chooseExportDirectory()
                    }
                    .controlSize(.small)

                    Button("Use Default") {
                        exportDirectoryPath = ""
                    }
                    .controlSize(.small)
                    .disabled(exportDirectoryPath.isEmpty)
                }
            }

            Section("System") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Launch at Login")
                        .font(.system(size: 13))

                    Text("Managed in System Settings \u{2192} General \u{2192} Login Items")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Toggle(isOn: .constant(false)) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hide desktop icons while capturing")
                        Text("Temporarily hides desktop icons during screen capture.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .toggleStyle(.switch)
            }
        }
        .formStyle(.grouped)
        .contentMargins(.top, 8, for: .scrollContent)
    }

    private func chooseExportDirectory() {
        let panel = NSOpenPanel()
        panel.title = "Choose Save Location"
        panel.prompt = "Choose"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.directoryURL = ScreendropPreferences.exportDirectory

        guard panel.runModal() == .OK,
              let url = panel.url else {
            return
        }

        exportDirectoryPath = url.path
    }
}
