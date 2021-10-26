#!/bin/bash

DEVICE=$1

if [ -z "$2" ] || [ "$2" != "onlyjson" ]; then
d=$(date +%Y%m%d)

if [ ! -z "$2" ]; then
d=$2
fi

FILENAME=lineage-18.1-"${d}"-UNOFFICIAL-"${DEVICE}".zip

oldd=$(grep filename $DEVICE.json | cut -d '-' -f 3)
md5=$(md5sum ~/lineageos/out/target/product/$DEVICE/$FILENAME | cut -d ' ' -f 1)
oldmd5=$(grep '"id"' $DEVICE.json | cut -d':' -f 2)
utc=$(grep ro.build.date.utc ~/lineageos/out/target/product/$DEVICE/system/build.prop | cut -d '=' -f 2)
oldutc=$(grep datetime $DEVICE.json | cut -d ':' -f 2)
size=$(wc -c ~/lineageos/out/target/product/$DEVICE/$FILENAME | cut -d ' ' -f 1)
oldsize=$(grep size $DEVICE.json | cut -d ':' -f 2)
oldurl=$(grep url $DEVICE.json | cut -d ' ' -f 9)

#This is where the magic happens
sed -i "s!${oldmd5}! \"${md5}\",!g" $DEVICE.json
sed -i "s!${oldutc}! \"${utc}\",!g" $DEVICE.json
sed -i "s!${oldsize}! \"${size}\",!g" $DEVICE.json
sed -i "s!${oldd}!${d}!" $DEVICE.json

d2=$(date +%Y%m%d-%H%M)

TAG=$(echo "${DEVICE}-${d2}")
url="https://github.com/meizucustoms/OTAUpdates/releases/download/${TAG}/${FILENAME}"
sed -i "s!${oldurl}!\"${url}\",!g" $DEVICE.json

echo "Creating new release..."

gh release create ${TAG} --title ${TAG} -F ~/Lineage-OTA/example_notes.txt ~/lineageos/out/target/product/${DEVICE}/${FILENAME}
else
echo "! onlyjson mode"
TAG="$(gh release list | grep Latest | sed 's/.*Latest.//g;s/202[0-9]\-.*//g;s/[[:space:]]//g')"
fi

git diff

echo "Pushing new JSON (${TAG})..."

read a

git add * && git commit -m "New OTA update - ${TAG}"
git push origin master

echo "Done."