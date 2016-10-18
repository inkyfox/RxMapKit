//
//  RxMKMapViewDelegateProxy.swift
//  Pods
//
//  Created by indy on 2016. 10. 17..
//
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import RxSwift
import RxCocoa

public typealias RxMKHandleViewForAnnotaion = (MKMapView, MKAnnotation) -> (MKAnnotationView?)
public typealias RxMKHandleRendererForOverlay = (MKMapView, MKOverlay) -> (MKOverlayRenderer)

public class RxMKMapViewDelegateProxy
    : DelegateProxy
    , MKMapViewDelegate
    , DelegateProxyType {
    
    var handleViewForAnnotation: RxMKHandleViewForAnnotaion? = nil
    var handleRendererForOverlay: RxMKHandleRendererForOverlay? = nil

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let mapView: MKMapView = castOrFatalError(object)
        mapView.delegate = castOptionalOrFatalError(delegate)
    }
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let mapView: MKMapView = castOrFatalError(object)
        return mapView.delegate
    }
    
}

extension RxMKMapViewDelegateProxy {
    
    @objc(mapView:viewForAnnotation:)
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return handleViewForAnnotation?(mapView, annotation)
    }

    @objc(mapView:rendererForOverlay:)
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return handleRendererForOverlay?(mapView, overlay) ?? MKOverlayRenderer(overlay: overlay)
    }
    
}

// Referred from RxCococa.swift because it's not public
//   They said: workaround for Swift compiler bug, cheers compiler team :)

func castOptionalOrFatalError<T>(_ value: Any?) -> T? {
    if value == nil {
        return nil
    }
    let v: T = castOrFatalError(value)
    return v
}

func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}

func castOrFatalError<T>(_ value: Any!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        fatalError("Failure converting from \(value) to \(T.self)")
    }
    
    return result
}

