import Foundation
import Combine

final class TemplateStore: ObservableObject {
    @Published var templates: [Template] = []

    private let fileURL: URL

    init() {
        let fm = FileManager.default

        // Note the "in: .userDomainMask" label here
        let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fm.homeDirectoryForCurrentUser

        let dir = appSupport.appendingPathComponent("PromptBuilder", isDirectory: true)

        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }

        self.fileURL = dir.appendingPathComponent("templates.json")

        load()
    }

    private func load() {
        let fm = FileManager.default

        if fm.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoded = try JSONDecoder().decode([Template].self, from: data)
                self.templates = decoded
            } catch {
                print("Failed to load templates.json, seeding defaults. Error: \(error)")
                self.templates = Template.defaultTemplates()
                save()
            }
        } else {
            self.templates = Template.defaultTemplates()
            save()
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(templates)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Failed to save templates.json: \(error)")
        }
    }

    // Hooks for the upcoming editor
    func add(_ template: Template) {
        templates.append(template)
        save()
    }

    func update(_ template: Template) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        // Remove in reverse order so indices stay valid
        for index in offsets.sorted(by: >) {
            templates.remove(at: index)
        }
        save()
    }
}
