//
//  MKMapView+Rx.swift
//  Pods
//
//  Created by indy on 2016. 10. 17..
//
//

import Foundation
import UIKit
import MapKit
import RxCocoa
import RxSwift


// MKMapViewDelegate

extension Reactive where Base: MKMapView {
    
    /**
     Reactive wrapper for `delegate`.
     
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var delegate: RxMKMapViewDelegateProxy {
        return RxMKMapViewDelegateProxy.proxy(for: base)
    }

    /**
     Installs delegate as forwarding delegate on `delegate`.
     Delegate won't be retained.
     
     It enables using normal delegate mechanism with reactive delegate mechanism.
     
     - parameter delegate: Delegate object.
     - returns: Disposable object that can be used to unbind the delegate.
     */
    public func setDelegate(_ delegate: MKMapViewDelegate)
        -> Disposable {
            return RxMKMapViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: base)
    }
    
}

/* MKMapViewDelegate */

extension Reactive where Base: MKMapView {

    public func handleViewForAnnotation(_ closure: RxMKHandleViewForAnnotaion?) {
        delegate.handleViewForAnnotation = closure
    }

    public func handleRendererForOverlay(_ closure: RxMKHandleRendererForOverlay?) {
        delegate.handleRendererForOverlay = closure
    }

}

/* MKMapViewDelegate */

extension Reactive where Base: MKMapView {
    
    private func methodInvokedWithParam1<T>(_ selector: Selector) -> Observable<T> {
        return delegate
            .methodInvoked(selector)
            .map { a in return try castOrThrow(T.self, a[1]) }
    }
    
    private func controlEventWithParam1<T>(_ selector: Selector) -> ControlEvent<T> {
        return ControlEvent(events: methodInvokedWithParam1(selector))
    }
    
    /**
     Wrapper of: func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool)
     */
    public var regionWillChange: ControlEvent<RxMKAnimatedProperty> {
        return ControlEvent(events:
            methodInvokedWithParam1(#selector(MKMapViewDelegate.mapView(_:regionWillChangeAnimated:)))
                .map(RxMKAnimatedProperty.init)
        )
    }
    
    /**
     Wrapper of: func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
     */
    public var regionDidChange: ControlEvent<(region: MKCoordinateRegion, isAnimated: Bool)> {
        return ControlEvent(events:
            methodInvokedWithParam1(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
                .map { [weak base] (isAnimated) -> (region: MKCoordinateRegion?, isAnimated: Bool) in
                    return (base?.region, isAnimated)
                }
                .filter { $0.0 != nil }
                .map { (region: $0.0!, isAnimated: $0.1) }
        )
    }
    
    /**
     Wrapper of: func mapViewWillStartLoadingMap(_ mapView: MKMapView)
     */
    public var willStartLoadingMap: ControlEvent<Void> {
        return ControlEvent(events:
            delegate.methodInvoked(#selector(MKMapViewDelegate.mapViewWillStartLoadingMap(_:)))
                .map { _ in return }
        )
    }
    
    /**
     Wrapper of: func mapViewDidFinishLoadingMap(_ mapView: MKMapView)
     */
    public var didFinishLoadingMap: ControlEvent<Void> {
        return ControlEvent(events:
            delegate.methodInvoked(#selector(MKMapViewDelegate.mapViewDidFinishLoadingMap(_:)))
                .map { _ in return }
        )
    }
    
    /**
     Wrapper of: func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error)
     */
    public var didFailLoadingMap: ControlEvent<Void> {
        return controlEventWithParam1(#selector(MKMapViewDelegate.mapViewDidFailLoadingMap(_:withError:)))
    }
    
    /**
     Wrapper of: func mapViewWillStartRenderingMap(_ mapView: MKMapView)
     */
    public var willStartRenderingMap: ControlEvent<Void> {
        return ControlEvent(events:
            delegate.methodInvoked(#selector(MKMapViewDelegate.mapViewWillStartRenderingMap(_:)))
                .map { _ in return }
        )
    }
    
    /**
     Wrapper of: func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool)
     */
    public var didFinishRenderingMap: ControlEvent<RxMKRenderingProperty> {
        return ControlEvent(events:
            methodInvokedWithParam1(#selector(MKMapViewDelegate.mapViewDidFinishRenderingMap(_:fullyRendered:)))
                .map(RxMKRenderingProperty.init)
        )
    }

    /**
     Wrapper of: func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView])
     */
    public var didAddAnnotationViews: ControlEvent<[MKAnnotationView]> {
        return ControlEvent(events:
            methodInvokedWithParam1(#selector(
                MKMapViewDelegate.mapView(_:didAdd:)!
                    as (MKMapViewDelegate) -> (MKMapView, [MKAnnotationView]) -> Void))
        )
    }
    
    /**
     Wrapper of: func mapViewDidFailLoadingMap(_ mapView: MKMapView, didSelect view: MKAnnotationView)
     */
    public var didSelectAnnotationView: ControlEvent<MKAnnotationView> {
        return controlEventWithParam1(#selector(MKMapViewDelegate.mapView(_:didSelect:)))
    }
    
    /**
     Wrapper of: func mapViewDidFailLoadingMap(_ mapView: MKMapView, didDeselect view: MKAnnotationView)
     */
    public var didDeselectAnnotationView: ControlEvent<MKAnnotationView> {
        return controlEventWithParam1(#selector(MKMapViewDelegate.mapView(_:didDeselect:)))
    }

    /**
     Wrapper of: func mapViewWillStartLocatingUser(_ mapView: MKMapView)
     */
    public var willStartLocatingUser: ControlEvent<Void> {
        return ControlEvent(events:
            delegate.methodInvoked(#selector(MKMapViewDelegate.mapViewWillStartLocatingUser(_:)))
                .map { _ in return }
        )
    }
    
    /**
     Wrapper of: func mapViewDidStopLocatingUser(_ mapView: MKMapView)
     */
    public var didStopLocatingUser: ControlEvent<Void> {
        return ControlEvent(events:
            delegate.methodInvoked(#selector(MKMapViewDelegate.mapViewDidStopLocatingUser(_:)))
                .map { _ in return }
        )
    }
    
    /**
     Wrapper of: func mapViewDidFailLoadingMap(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation)
     */
    public var didUpdateUserLocation: ControlEvent<MKUserLocation> {
        return controlEventWithParam1(#selector(MKMapViewDelegate.mapView(_:didUpdate:)))
    }
    
    /**
     Wrapper of: func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error)
     */
    public var didFailToLocateUser: ControlEvent<Error> {
        return controlEventWithParam1(#selector(MKMapViewDelegate.mapView(_:didFailToLocateUserWithError:)))
    }

    /**
     Wrapper of: func mapViewWillStartLoadingMap(_ mapView: MKMapView)
     */
    public var dragStateOfAnnotationView: ControlEvent<(annotationView: MKAnnotationView, newState: MKAnnotationViewDragState, oldState: MKAnnotationViewDragState)> {
        return ControlEvent(events:
            delegate.methodInvoked(#selector(MKMapViewDelegate.mapView(_:annotationView:didChange:fromOldState:)))
                .map { a in
                    let annotationView = try castOrThrow(MKAnnotationView.self, a[1])
                    
                    guard let newState = MKAnnotationViewDragState(rawValue: try castOrThrow(UInt.self, a[2])) else {
                        throw RxCocoaError.castingError(object: a[2], targetType: MKAnnotationViewDragState.self)
                    }
                    guard let oldState = MKAnnotationViewDragState(rawValue: try castOrThrow(UInt.self, a[3])) else {
                        throw RxCocoaError.castingError(object: a[3], targetType: MKAnnotationViewDragState.self)
                    }
                    
                    return (annotationView, newState, oldState)
            }
        )
    }

    /**
     Wrapper of: func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer])
     */
    public var didAddRenderers: ControlEvent<[MKOverlayRenderer]> {
        return ControlEvent(events:
            methodInvokedWithParam1(#selector(
                MKMapViewDelegate.mapView(_:didAdd:)!
                    as (MKMapViewDelegate) -> (MKMapView, [MKOverlayRenderer]) -> Void))
        )
    }

}

/* MKMapView: Visible Portion */

extension Reactive where Base: MKMapView {

    public var region: AnyObserver<MKCoordinateRegion> {
        return Binder(base) { control, region in
                   control.region = region
               }.asObserver()
    }
    
    public var regionToAnimate: AnyObserver<MKCoordinateRegion> {
        return Binder(base) { control, region in
                    control.setRegion(region, animated: true)
               }.asObserver()
    }

    public var center: AnyObserver<CLLocationCoordinate2D> {
        return Binder(base) { control, centerCoordinate in
                   control.centerCoordinate = centerCoordinate
               }.asObserver()
    }
    
    public var centerToAnimate: AnyObserver<CLLocationCoordinate2D> {
        return Binder(base) { control, centerCoordinate in
                   control.setCenter(centerCoordinate, animated: true)
               }.asObserver()
    }
    
    public var annotationsToShow: AnyObserver<[MKAnnotation]> {
        return Binder(base) { control, annotationsToShow in
                   control.showAnnotations(annotationsToShow, animated: false)
               }.asObserver()
    }
    
    public var annotationsToShowToAnimate: AnyObserver<[MKAnnotation]> {
        return Binder(base) { control, annotationsToShow in
                   control.showAnnotations(annotationsToShow, animated: true)
               }.asObserver()
    }
    
    public var visibleMapRect: AnyObserver<MKMapRect> {
        return Binder(base) { control, visibleMapRect in
                   control.visibleMapRect = visibleMapRect
               }.asObserver()
    }
    
    public var visibleMapRectToAnimate: AnyObserver<MKMapRect> {
        return Binder(base) { control, visibleMapRect in
                   control.setVisibleMapRect(visibleMapRect, animated: true)
               }.asObserver()
    }

    public var camera: AnyObserver<MKMapCamera> {
        return Binder(base) { control, camera in
                   control.camera = camera
               }.asObserver()
    }
    
    public var cameraToAnimate: AnyObserver<MKMapCamera> {
        return Binder(base) { control, camera in
                   control.setCamera(camera, animated: true)
               }.asObserver()
    }
    
}

/* MKMapView: User’s Location */

extension Reactive where Base: MKMapView {
    
    public var showsUserLocation: ControlProperty<Bool> {
        return ControlProperty(values: observeWeakly(Bool.self, "showsUserLocation").filter { $0 != nil }.map { $0! },
                               valueSink: Binder(base) { control, showsUserLocation in
                                    control.showsUserLocation = showsUserLocation
                                }.asObserver()
        )
    }
    
    public var userLocation: ControlEvent<MKUserLocation> {
        return didUpdateUserLocation
    }

    public var userTrackingMode: AnyObserver<MKUserTrackingMode> {
        return Binder(base) { control, userTrackingMode in
                   control.userTrackingMode = userTrackingMode
               }.asObserver()
    }
    
    public var userTrackingModeToAnimate: AnyObserver<MKUserTrackingMode> {
        return Binder(base) { control, userTrackingMode in
                   control.setUserTrackingMode(userTrackingMode, animated: true)
               }.asObserver()
    }

}

/* MKMapView: Map properties */

extension Reactive where Base: MKMapView {
    
    public var mapType: AnyObserver<MKMapType> {
        return Binder(base) { control, mapType in
                  control.mapType = mapType
               }.asObserver()
    }
    
    public var isZoomEnabled: AnyObserver<Bool> {
        return Binder(base) { control, isZoomEnabled in
                   control.isZoomEnabled = isZoomEnabled
               }.asObserver()
    }
    
    public var isScrollEnabled: AnyObserver<Bool> {
        return Binder(base) { control, isScrollEnabled in
                   control.isScrollEnabled = isScrollEnabled
               }.asObserver()
    }
    
    public var isRotateEnabled: AnyObserver<Bool> {
        return Binder(base) { control, isRotateEnabled in
                   control.isRotateEnabled = isRotateEnabled
               }.asObserver()
    }
    
    public var isPitchEnabled: AnyObserver<Bool> {
        return Binder(base) { control, isPitchEnabled in
                   control.isPitchEnabled = isPitchEnabled
               }.asObserver()
    }
    
    @available(iOS 9.0, *)
    public var showsCompass: AnyObserver<Bool> {
        return Binder(base) { control, showsCompass in
                   control.showsCompass = showsCompass
               }.asObserver()
    }
    
    @available(iOS 9.0, *)
    public var showsScale: AnyObserver<Bool> {
        return Binder(base) { control, showsScale in
                   control.showsScale = showsScale
               }.asObserver()
    }
    
    @available(iOS 9.0, *)
    public var showsPointsOfInterest: AnyObserver<Bool> {
        return Binder(base) { control, showsPointsOfInterest in
                   control.showsPointsOfInterest = showsPointsOfInterest
               }.asObserver()
    }
    
    @available(iOS 9.0, *)
    public var showsBuildings: AnyObserver<Bool> {
        return Binder(base) { control, showsBuildings in
                   control.showsBuildings = showsBuildings
               }.asObserver()
    }
    
    @available(iOS 9.0, *)
    public var showsTraffic: AnyObserver<Bool> {
        return Binder(base) { control, showsTraffic in
                   control.showsTraffic = showsTraffic
               }.asObserver()
    }
    
}

public struct RxMKAnimatedProperty {
    public let isAnimated: Bool
}

public struct RxMKRenderingProperty {
    public let isFullyRendered: Bool
}
