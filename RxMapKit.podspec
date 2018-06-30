Pod::Spec.new do |s|
  s.name             = "RxMapKit"
  s.version          = "1.2.0"
  s.summary          = "RxSwift reactive wrapper for MapKit."
  s.homepage         = "https://github.com/inkyfox/RxMapKit"
  s.license          = 'MIT'
  s.author           = { "Yongha Yoo" => "inkyfox@oo-v.com" }
  s.platform         = :ios, "8.0"
  s.source           = { :git => "https://github.com/inkyfox/RxMapKit.git", :tag => s.version.to_s }
  s.requires_arc          = true
  s.ios.deployment_target = '8.0'
  s.source_files          = 'Sources/*.swift'
  s.dependency 'RxSwift', '~> 4.2'
  s.dependency 'RxCocoa', '~> 4.2'
  s.swift_version = '4.1'
end
