//
//  Types.swift
//  Weather test
//
//  Created by Anastasia on 20.07.2022.
//

import UIKit
import CoreLocation

typealias EmptyBlock = () -> Void
typealias StringBlock = (String) -> Void
typealias BoolBlock = (Bool) -> Void
typealias IndexPathBlock = (IndexPath) -> Void
typealias LocationBlock = (CLLocationCoordinate2D?) -> Void
typealias ImageBlock = (UIImage) -> Void
typealias ImageOptionalBlock = (UIImage?) -> Void
typealias ImagesBlock = ([UIImage]) -> Void
typealias UrlBlock = (URL) -> Void
typealias UrlOptionalBlock = (URL?) -> Void
