//
//  DiskSpaceEater.swift
//  DiskSpaceEater
//
//  Created by Shinichiro Oba on 2017/07/16.
//  Copyright © 2017 Shinichiro Oba. All rights reserved.
//

import Foundation

struct DiskSpaceEater {
    
    enum CreateFileError: Error {
        case fopen(String)
        case fwrite(String)
        case fclose(String)
    }
    
    let targetUrl: URL
    
    func createEmptyFiles(fileSize: Int, num: Int, progress: ((Float) -> Void)? = nil) throws {
        progress?(0)
        for n in 1...num {
            let filename = UUID().uuidString
            try createEmptyFile(filename: filename, targetSize: fileSize)
            progress?(Float(n) / Float(num))
        }
    }
    
    func createEmptyFile(filename: String, targetSize: Int) throws {
        let buffer = Array<CUnsignedChar>(repeating: 0, count: 4096)
        let bufferSize = buffer.count
        
        let filepath = targetUrl.appendingPathComponent(filename).path
        guard let handle = fopen(filepath, "wb") else {
            throw CreateFileError.fopen(filename)
        }
        
        defer {
            fclose(handle)
        }
        
        var restOfTargetSize = targetSize
        while restOfTargetSize > 0 {
            let writingSize = min(restOfTargetSize, bufferSize)
            let writtenSize = fwrite(buffer, 1, writingSize, handle)
            guard writtenSize == writingSize else {
                throw CreateFileError.fwrite(filename)
            }
            restOfTargetSize -= writtenSize
        }
    }

    func deleteAllFiles(progress: ((Float) -> Void)? = nil) throws -> Int {
        let urls = try FileManager.default.contentsOfDirectory(at: targetUrl, includingPropertiesForKeys: nil)
        progress?(0)
        for (index, url) in urls.enumerated() {
            try FileManager.default.removeItem(at: url)
            progress?(Float(index + 1) / Float(urls.count))
        }
        return urls.count
    }
}
