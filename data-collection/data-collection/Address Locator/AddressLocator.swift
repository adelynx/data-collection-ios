// Copyright 2017 Esri
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

/// This class facilitates reverse geocoding, contingent on app work mode and reachability.
class AddressLocator {
    
    // Online locator using the world geocoder service.
    private lazy var onlineLocator = AGSLocatorTask(url: .geocodeService)
    
    // Offline locator using the side loaded 'AddressLocator'.
    private lazy var offlineLocator = AGSLocatorTask(name: .offlineLocator)
    
    private var appContextAwareLocator: AGSLocatorTask {
        // We want to use the online locator if the work mode is online and the app has reachability.
        if appContext.workMode == .online && appReachability.isReachable {
            return onlineLocator
        }
        // Otherwise, we'll use the offline locator.
        else {
            return offlineLocator
        }
    }
    /// Reverse geocode an address from a map point.
    ///
    /// - Parameters:
    ///   - point: The point used in the reverse geocode operation.
    ///   - completion: A closure called upon completion of the reverse geocode.
    ///   - result: The result of the reverse geocode operation, with either the
    ///   address or an error.
    func reverseGeocodeAddress(for point: AGSPoint, completion: @escaping (_ result: Result<String, Error>) -> Void) {
        let locator = appContextAwareLocator
        locator.load { [weak self] (error) in
            // Ensure the loaded locator matches the app context aware locator.
            // The app context might have changed since the locator started loading.
            guard locator == self?.appContextAwareLocator else {
                completion(.failure(NSError.unknown))
                return
            }
            // If the locator load failed, end early.
            if let error = error {
                completion(.failure(error))
                return
            }
            // We need to set the geocode parameters for storage true because the results of this reverse geocode is persisted to a table.
            // Please familiarize yourself with the implications of this credits-consuming operation:
            // https://developers.arcgis.com/rest/geocode/api-reference/geocoding-free-vs-paid.htm
            let params: AGSReverseGeocodeParameters = {
                let params = AGSReverseGeocodeParameters()
                params.forStorage = true
                return params
            }()
            // Perform the reverse geocode task.
            locator.reverseGeocode(withLocation: point, parameters: params) { (results, error) in
                if let error = error {
                    completion(.failure(error))
                }
                else if
                    let attributes = results?.first?.attributes,
                    let address = (attributes[.address] ?? attributes[.matchAddress]) as? String {
                    completion(.success(address))
                }
                else {
                    assertionFailure("Locator task unsupporting of required attribute key (\"\(String.address)\" for online locator, \"\(String.matchAddress)\" for offline locator).")
                }
            }
        }
    }
    
    func removeCredentialsFromServices() {
        onlineLocator.credential = nil
        offlineLocator.credential = nil
    }
    
    deinit {
        removeCredentialsFromServices()
    }
}

private extension String {
    static let address = "Address"
    static let matchAddress = "Match_addr"
    static let offlineLocator = "AddressLocator"
}
