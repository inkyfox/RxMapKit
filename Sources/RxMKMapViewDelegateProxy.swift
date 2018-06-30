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

extension MKMapView: HasDelegate {
    public typealias Delegate = MKMapViewDelegate
}

public class RxMKMapViewDelegateProxy
    : DelegateProxy<MKMapView, MKMapViewDelegate>
    , DelegateProxyType
    , MKMapViewDelegate {
    
    //#MARK: DelegateProxy
    
    public weak private(set) var mapView: MKMapView?

    init(mapView: MKMapView) {
        self.mapView = mapView
        super.init(parentObject: mapView, delegateProxy: RxMKMapViewDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxMKMapViewDelegateProxy(mapView: $0) }
    }
    
    //#MARK: Delegate

    var handleViewForAnnotation: RxMKHandleViewForAnnotaion? = nil
    var handleRendererForOverlay: RxMKHandleRendererForOverlay? = nil
    
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

