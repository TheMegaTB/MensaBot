//
//  LogMiddleware.swift
//  App
//
//  Created by Til Blechschmidt on 23.01.19.
//

import Vapor

class LogMiddleware: Middleware {
    let file: URL

    init(path: URL) {
        self.file = path
    }

    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let csv: [String] = [
            Date().timeIntervalSince1970.description,
            request.http.urlString,
            request.http.remotePeer.description,
            request.http.headers.firstValue(name: .userAgent) ?? "no-user-agent"
        ]
        let csvLine = csv.joined(separator: "|")
        do {
            try csvLine.appendLineToURL(fileURL: file)
        } catch {
            print("Failed to write log \(error)")
        }

        return try next.respond(to: request)
    }
}

extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }

    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
