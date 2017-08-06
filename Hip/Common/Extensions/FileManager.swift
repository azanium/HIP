//
//  FileManager.swift
//  Hip
//
//  Created by Suhendra Ahmad on 8/7/17.
//  Copyright © 2017 Ainasoft. All rights reserved.
//

import Foundation

extension FileManager {
    func merge(files: [URL], to destination: URL, chunkSize: Int = 1000000) throws {
        try FileManager.default.createFile(atPath: destination.path, contents: nil, attributes: nil)
        let writer = try FileHandle(forWritingTo: destination)
        try files.forEach({ partLocation in
            let reader = try FileHandle(forReadingFrom: partLocation)
            var data = reader.readData(ofLength: chunkSize)
            while data.count > 0 {
                writer.write(data)
                data = reader.readData(ofLength: chunkSize)
            }
            reader.closeFile()
        })
        writer.closeFile()
    }
}
