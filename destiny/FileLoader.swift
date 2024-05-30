//
//  FileLoader.swift
//  destiny
//
//  Created by Ueta, Lucas T on 9/22/23.
//

import Foundation

struct RawGraphics: Codable {
    var names: [String], graphics: [[String]]
}

struct Option: Codable {
    var text: String, next: Int
}

struct Chapter: Codable {
    var _id: Int, graphic: String?, text: String?, next: [Option]
}

struct Story: Codable {
    var chapters: [Chapter]
}

class FileLoader {
    
    static func readLocalFile(_ filename: String) -> Data? {
        guard let file = Bundle.main.path(forResource: filename, ofType: "json")
            else {
                fatalError("Unable to locate file \"\(filename)\" in main bundle.")
        }
        
        do {
            return try String(contentsOfFile: file).data(using: .utf8)
        } catch {
            fatalError("Unable to load \"\(filename)\" from main bundle:\n\(error)")
        }
    }
    
    static func format(_ raw: RawGraphics) -> [String: String] {
        var graphics: [String: String] = [:]
        for i in 0...(raw.names.count - 1) {
            graphics[raw.names[i]] = raw.graphics[i].reduce("") { return $0 + "\n" + $1 }
        }
        return graphics
    }
    
    static func loadGraphics(_ data: Data) -> [String: String] {
        do {
            let raw = try JSONDecoder().decode(RawGraphics.self, from: data)
            return format(raw)
        }
        catch { fatalError("Unable to decode  \"\(data)\" as \(RawGraphics.self):\n\(error)") }
    }
    
    static func loadStory(_ data: Data) -> [Chapter] {
        do {
            let raw = try JSONDecoder().decode(Story.self, from: data)
            return raw.chapters
        }
        catch { fatalError("Unable to decode  \"\(data)\" as \(Story.self):\n\(error)")}
    }
}
