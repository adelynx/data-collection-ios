//// Copyright 2018 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import ArcGIS

// This class extension is used to creating and removing directories and items needed for the app in the device's file documents directory.
extension FileManager {
    /// Build a temporary directory, if needed, to store a map as it downloads.
    ///
    /// - Throws: FileManager errors thrown as a result of building the temporary offline map directory.
    func prepareTemporaryOfflineMapDirectory() throws {
        let url: URL = .temporaryOfflineMapDirectoryURL(forWebMapItemID: .webMapItemID)
        try createDirectory(at: url, withIntermediateDirectories: true)
        try removeItem(at: url)
    }
    
    // MARK: Offline Directory    
    func prepareOfflineMapDirectory() throws {
        let url: URL = .offlineMapDirectoryURL(forWebMapItemID: .webMapItemID)
        try createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
    
    func deleteContentsOfOfflineMapDirectory() throws {
        let url: URL = .offlineMapDirectoryURL(forWebMapItemID: .webMapItemID)
        try removeItem(at: url)
    }
}

extension URL {
    
    /// Build an app-specific URL to a temporary directory used to store the offline map during download.
    ///
    /// - Parameter itemID: The portal itemID that corresponds to your web map.
    ///
    /// - Returns: App-specific URL.
    
    static func temporaryOfflineMapDirectoryURL(forWebMapItemID itemID: String) -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(.dataCollection)
            .appendingPathComponent(.offlineMap)
            .appendingPathComponent(itemID)
    }
    
    /// Build an app-specific URL to where the offline map is stored in the documents directory once downloaded.
    ///
    /// - Parameter itemID: The portal itemID that corresponds to your web map.
    ///
    /// - Returns: App-specific URL.
    
    static func offlineMapDirectoryURL(forWebMapItemID itemID: String) -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(.dataCollection)
            .appendingPathComponent(.offlineMap)
            .appendingPathComponent(itemID)
    }
}

private extension String {
    static let dataCollection = "data_collection"
    static let offlineMap = "offlineMap"
}
