# To do:
# - Get API keys from somewhere else
# - Change installation warnings

# Filenames
input="$1"
root="$(echo "$input" | sed 's/.md//g' )"
links="$root.links.txt"
archivedLinks="captures.log" ##"$root.links.archived.txt"
errors="error-json.log"
output="$root.longnow.md"

## Directories
initialDir="$(pwd)"
workdir="longnow-$root"

## Move to work dir
function moveToWorkDir(){
  mkdir -p "$workdir"
  cp "$input" "$workdir/$input"
  cd "$workdir"
}

## Extract markdown links
function extractMarkdownLinks(){ # Use: Takes a markdown file file.md, extracts all links, finds the unique ones and saves them to file.md.links
  links2="$root.links2.txt"
  echo ""
  echo "Extracting links..."
  
  rm -f "$links"
  grep -Eoi '\]\((.*)\)' "$input" | grep -Eo '(http|https)://[^)]+' >> "$links"
  
  awk '!seen[$0]++' "$links" > "$links2" && mv "$links2" "$links"

  echo "Done extracting links"
}

## Push to Archive
function pushToArchive(){
# Use: Takes a txt file with one link on each line and pushes all the links to the internet archive. Saves those links to a textfile
# References: 
# https://unix.stackexchange.com/questions/181254/how-to-use-grep-and-cut-in-script-to-obtain-website-urls-from-an-html-file
# https://github.com/oduwsdl/archivenow
# For the double underscore, see: https://stackoverflow.com/questions/13797087/bash-why-double-underline-for-private-functions-why-for-bash-complet/15181999  
  
  echo ""
  echo "Pushing to archive.org..."
  numLinesLinkFile=$(wc -l "$links" | awk '{ print $1 }')
  totalTimeInMinutes=$(echo "scale=0; ($numLinesLinkFile*7.5 + 60*$numLinesLinkFile/15)/60" | bc)
  echo "Expected to take ~$totalTimeInMinutes mins."
  echo ""
	
  /home/loki/.bash/src/longnow/spn/wayback-machine-spn-scripts/spn.sh -a [my private key] -f . -p 3 "$links"
  
  echo "Done pushing links to archive.org"
  echo ""
}

## Add archive links to file
function addArchiveLinksToFile(){
    
  echo "Creating longnow file at $output"

  rm -f "$output"
  cp "$input" "$output"
  
  while IFS= read -r url
  do
    wait
    archivedUrl=$( ( grep "$url$" "$archivedLinks"; grep "$url/$" "$archivedLinks") | tail -1)
    if [ "$archivedUrl" != ""  ]; then
      ## echo "Url: $url"
      ## echo "ArchivedUrl: $archivedUrl"
      urlForSed="${url//\//\\/}"
      archiveUrlForSed="${archivedUrl//\//\\/}"
      sed -i "s/$urlForSed)/$urlForSed) ([a](https:\/\/web.archive.org$archiveUrlForSed))/g" "$output"
    ##else
      ##echo "There was an error for $url; see the $errorsFile"
    fi
  done < "$links"
  
  echo "Done."
}

## Explain installation
function explainArchiveNowInstallation(){
  echo "Required archivenow utility not found in path."
  echo "Install with \$ pip install archivenow"
  echo "(resp. \$ pip3 install archivenow)"
  echo "Or follow instructions on https://github.com/oduwsdl/archivenow"
}

function explainJqInstallation(){
  echo "Required jq utility not found in path."
  echo "Install with your package manager, e.g., \$ sudo apt install jq"
  echo "Or follow instructions on https://stedolan.github.io/jq/download/"
}
## Report errors
function reportErrors(){
  if test -f "$errors"; then
    echo "It seems that there are errors. To view and deal with them, see the $errors file"
  fi
}

## Clean up
function cleanup(){
  cp "$output" "../$output"
  cd "$initialDir"
}

## Main
function main(){
  doesArchiveNowExist="$(whereis "archivenow")"
  doesJqExist="$(whereis "jq")"
  if [ "$doesArchiveNowExist" == "archivenow:" ]; then
    explainArchiveNowInstallation
	elif [ "$doesJqExist" == "jq:" ]; then
		explainJqInstallation
  else
    moveToWorkDir
    extractMarkdownLinks
    pushToArchive
    addArchiveLinksToFile
    reportErrors
    cleanup
  fi 
}
main

