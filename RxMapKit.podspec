Pod::Spec.new do |s|
  s.name             = "RxMapKit"
  s.version          = "1.0.1"
  s.summary          = "RxSwift reactive wrapper for MapKit."
  s.description      = <<-DESC
# RxMapKit
![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg)


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

## Requirements

RxMapKit requires Swift 3.0 and dedicated versions of RxSwift 3.0.0-beta.2 (Xcode8+ and iOS8+)

## Author

[Yongha Yoo](http://inkyfox.oo-v.com)

## License

MIT
                        DESC
  s.homepage         = "https://github.com/inkyfox/RxMapKit"
  s.license          = 'MIT'
  s.author           = { "Yongha Yoo" => "inkyfox@oo-v.com" }
  s.source           = { :git => "https://github.com/inkyfox/RxMapKit.git", :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '8.0'

  s.source_files          = 'Sources/*.swift'

  s.dependency 'RxSwift', '~> 3.0.0-beta.2'
  s.dependency 'RxCocoa', '~> 3.0.0-beta.2'

  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '3.0'
  }

end
