# RxMapKit
![Swift](https://img.shields.io/badge/Swift-4.1-orange.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/RxMapKit.svg?style=flat)](http://cocoapods.org/pods/RxMapKit)
[![License](https://img.shields.io/cocoapods/l/RxMapKit.svg?style=flat)](http://cocoapods.org/pods/RxMapKit)
[![Platform](https://img.shields.io/cocoapods/p/RxMapKit.svg?style=flat)](http://cocoapods.org/pods/RxMapKit)


RxMapKit is a [RxSwift](https://github.com/ReactiveX/RxSwift) wrapper for [MapKit](https://developer.apple.com/reference/mapkit)

## Example Usages

### Setup MKMapView
```swift
// Setup MKMapview from Interface Builder
@IBOutlet weak var mapView: MKMapView!
```
or
```swift
// Setup MKMapview
let mapView = MKMapView(frame: self.view.bounds)
self.view.addSubview(mapView)
```

### Observing properties
```swift
// Camera position

mapView.rx.regionDidChange.asDriver()
    .drive(onNext: { print("Did region change: \($0.region) isAnimated \($0.isAnimated)") })
    .addDisposableTo(disposeBag)

// Marker tapped

mapView.rx.didTapMarker.asDriver()
    .drive(onNext: { print("Did tap marker: \($0)") })
    .addDisposableTo(disposeBag)

// Update marker icon 

mapView.rx.didSelectAnnotationView.asDriver()
    .drive(onNext: { $0.image = #imageLiteral(resourceName: "marker_selected") })
    .addDisposableTo(disposeBag)

mapView.rx.didDeselectAnnotationView.asDriver()
    .drive(onNext: { $0.image = #imageLiteral(resourceName: "marker_normal") })
    .addDisposableTo(disposeBag)
                
```

### Binding properties
```Swift
// Camera animations

button.rx.tap
    .map { MKMapCamera(lookingAtCenter: center, fromDistance: 50000, pitch: 30, heading: 45) }
    .bindTo(mapView.rx.cameraToAnimate)
    .addDisposableTo(disposeBag)
    
button.rx.tap
    .map { CLLocationCoordinate2D(latitude: 33.3659424, longitude: 126.3476852) }
    .bindTo(mapView.rx.centerToAnimate)
    .addDisposableTo(disposeBag)

button.rx.tap
    .map { [annotation0, annotaion1] }
    .bindTo(mapView.rx.annotationsToShowToAnimate)
    .addDisposableTo(disposeBag)

// Properties

button.rx.tap
    .map { .satellite }
    .bindTo(mapView.rx.mapType)
    .addDisposableTo(disposeBag)
    
button.rx.tap
    .map { false }
    .bindTo(mapView.rx.showsTraffic)
    .addDisposableTo(disposeBag)

```

### Delegates which have a return value
```Swift
//  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?

mapView.rx.handleViewForAnnotation { (mapView, annotation) in
    if let _ = annotation as? MKUserLocation {
        return nil
    } else {
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "reusableIdentifier") ??
            MKAnnotationView(annotation: annotation, reuseIdentifier: "reusableIdentifier")
        view.image = #imageLiteral(resourceName: "marker_normal")
        view.canShowCallout = true
        return view
    }
}

// func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer

mapView.rx.handleRendererForOverlay { (mapView, overlay) in
    if overlay is MKCircle {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.green.withAlphaComponent(0.8)
        renderer.lineWidth = 4
        renderer.fillColor = UIColor.green.withAlphaComponent(0.3)
        return renderer
    } else {
        return MKOverlayRenderer(overlay: overlay)
    }
}

```

## Installation

### CocoaPods

```Ruby
pod 'RxMapKit'
```

### Carthage
```
github "inkyfox/RxMapKit"
```

## Requirements

- Swift 4.1
- [RxSwift](https://github.com/ReactiveX/RxSwift) 4.2
- [RxCocoa](https://github.com/ReactiveX/RxSwift) 4.2

## Author

[Yongha Yoo](http://inkyfox.oo-v.com)

## License

MIT
