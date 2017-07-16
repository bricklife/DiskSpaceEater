//
//  FileSystemInfo.swift
//  DiskSpaceEater
//
//  Created by Shinichiro Oba on 2017/07/16.
//  Copyright © 2017 Shinichiro Oba. All rights reserved.
//

import Foundation

struct FileSystemInfo {

    let systemFreeSize: Int64
    let systemSize: Int64
    
    var freeSpace: Double? {
        guard systemFreeSize >= 0, systemSize > 0  else {
            return nil
        }
        return Double(systemFreeSize) / Double(systemSize) * 100.0
    }
    
    init?(url: URL) {
        let attributes = try? FileManager.default.attributesOfFileSystem(forPath: url.path)
        
        guard let systemFreeSize = attributes?[.systemFreeSize] as? NSNumber,
            let systemSize = attributes?[.systemSize] as? NSNumber else {
                return nil
        }
        
        self.systemFreeSize = systemFreeSize.int64Value
        self.systemSize = systemSize.int64Value
    }
}
