#!/bin/bash

echo "******************请输入你要更新的tag版本号******************"
read tag
git tag $tag
git push origin --tags

pod repo push yykjpodspec RxMapKit.podspec