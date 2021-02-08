#!/bin/bash

echo "******************请输入你要更新的tag版本号******************"
read tag
git tag $tag
git push origin --tags

pod repo push yykjpodspec YYKJExtensionsKit.podspec --skip-import-validation
pod repo push yykjpodspec YYKJNavigatorKit.podspec --skip-import-validation
pod repo push yykjpodspec YYKJAppConfigKit.podspec --skip-import-validation
pod repo push yykjpodspec YYKJServiceKit.podspec --skip-import-validation
pod repo push yykjpodspec YYKJComponentManagerKit.podspec --skip-import-validation
pod repo push yykjpodspec YYKJKit.podspec --skip-import-validation