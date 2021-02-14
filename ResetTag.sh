#!/bin/bash

# 当前脚本所在根目录
CRTDIR=$(pwd)

# 删除Tag
removeTag() {
    echo "******************请输入你要删除的tag版本号:******************"
    read tag
    git tag -d $tag
    git push origin :refs/tags/$tag

    echo "******************请输入你要重新设置的tag版本号:******************"
    read resetTag
    git tag $resetTag
    git push origin --tags
}

# choose() {
#     if [ $a == 1 ]; then
#         cd "$CRTDIR/CCSourcesKit"
#     elif [ $a == 2]; then
#         cd "$CRTDIR/CCMyModule"
#     else
#         cd "$CRTDIR/CCContactModule"
#     fi
# }

# echo "******************你将要重置哪个工程呢?******************
# 1.CCSourcesKit
# 2.CCMyModule
# 3.CCContactModule"

# read a
# choose

removeTag
echo "******************清除Tag: \"$tag\"完成, 清除Pod缓存: \"$pod\"完成******************"