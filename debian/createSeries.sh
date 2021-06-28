#!/bin/bash
stemFolder="$(pwd)/$1"
stemFolderName="$1"
seriesFolder="$(pwd)/$1~series"
seriesNames=("focal" "groovy" "hirsute" "impish")

rm -r "$seriesFolder"
mkdir "$seriesFolder"

for seriesName in "${seriesNames[@]}"; do

  # Create corresponding folder
  newSeriesFolder="$seriesFolder/$stemFolderName~$seriesName"
  echo "$seriesName"
  cp -r "$stemFolder" "$newSeriesFolder" 

  cd "$newSeriesFolder"

  # Make
  dh_make --createorig -c mit --indep -y
  wait
  
  # Modify corresponding files
  touch debian/install
  echo "longnow usr/bin" > debian/install ## Add files to debian/install; depends on the files
  
  cd debian
  # Replace "unstable" for the series name ("bionic", "focal",...)
  sed -i "s|unstable|$seriesName|g" changelog
  
  # Edit the control file; change "unknown" section to "utils" (or some other section)
  sed -i 's|Section: unknown|Section: utils|g' control
  
  # Cosmetic stuff
  # Delete the .ex and .docs  and README.Debian files
  rm *.ex; rm *.docs; rm README*; rm *.EX
  sed -i 's|<insert the upstream URL, if relevant>|https://github.com/NunoSempere/longNowForMd|g' control
  sed -i 's|Nuno <nuno@unknown>|Nuno Sempere <nuno.semperelh@gmail.com>|g' *
  
  # Build
  cd ..
  debuild -S
  wait
  cd ..
  
  dput ppa:nunosempere/longnowformd longnow_0.5~$seriesName-1_source.changes
  wait
done

## How to use: ./createSeries.sh longnow-0.5
