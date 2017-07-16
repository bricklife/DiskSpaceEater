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
    
    func createEmptyFiles(fileSize: Int, num: Int) throws {
        for _ in 0..<num {
            let filename = UUID().uuidString
            try createEmptyFile(filename: filename, targetSize: fileSize)
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

    func deleteAllFiles() throws -> Int {
        let urls = try FileManager.default.contentsOfDirectory(at: targetUrl, includingPropertiesForKeys: nil)
        for url in urls {
            try FileManager.default.removeItem(at: url)
        }
        return urls.count
    }
}
