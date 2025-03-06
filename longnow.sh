# Filenames
input="$1"
root="$(echo "$input" | sed 's/.md//g' )"
links="$root.links.txt"
archivedLinks="$root.links.archived.txt"
errors="$root.errors.txt"
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

function getOssFrontend(){
  nitterUrl=$(echo "$1" | sed -E 's/(https?:\/\/)(www\.)?(twitter\.com|x\.com)/\1nitter.net/g')
  echo $nitterUrl
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

  ## rm -f "$archivedLinks"
  rm -f "$errors"
  touch "$archivedLinks"
  touch "$errors"
  
  ## How to deal with errors that arise
  echo "If this file contains errors, you can deal with them as follows:" >> "$errors"
  echo "- Do another pass with \$ longnow yourfile.md. If you don't delete yourfile.md.links.archived, past archive links are remembered, and only the links which are not there are sent again"  >> "$errors"
  echo "- Input the offending links manually to https://archive.org/, add the results to the yourfile.md.links.archived file manually, and then do another pass with \$ longnow yourfile.md" >> "$errors"
  echo "" >> "$errors"
  
  ## Main body
  counter=1
  while IFS= read -r line
  do
    wait
    if [ $(($counter % 15)) -eq 0 ]; then
      printf "Archive.org doesn't accept more than 15 links per min; sleeping for 1min...\n\n"
      sleep 1m
    fi
    echo "Url: $line"
    oss_url="$(getOssFrontend $line)"
    urlAlreadyContainedInLocalArchivedLinks=$( ( grep "$oss_url$" "$archivedLinks"; grep "$oss_url/$" "$archivedLinks" )  | tail -1 )

    if [ "$urlAlreadyContainedInLocalArchivedLinks" == "" ]; then
      urlAlreadyInArchiveOnline="$(curl --silent http://archive.org/wayback/available?url=$oss_url |  jq '.archived_snapshots.closest.url' | sed 's/"//g' | sed 's/null//g' )"
      if [ "$urlAlreadyInArchiveOnline" == "" ]; then
        echo "Sending to archive..."
        archiveURL=$(archivenow --ia $oss_url)
        if [[ "$archiveURL" == "Error"* ]]; then
          echo "$line" >> "$errors"
          echo "$archiveURL" >> "$errors"
          echo "" >> "$errors"
          echo "There was an error. See $errors for how to deal with it."
					echo ""
        else
            echo "$archiveURL" >> "$archivedLinks"
        fi
        counter=$((counter+1))
        numSecondsSleep=$((5+ ($RANDOM%15)))
      else
        echo "Already in archive.org: $urlAlreadyInArchiveOnline"
        echo "$urlAlreadyInArchiveOnline" >> "$archivedLinks"
				echo ""
        numSecondsSleep=0
      fi
    elif [ ! -z "$urlAlreadyContainedInLocalArchivedLinks" ]; then
      echo "Already in local archive: $urlAlreadyContainedInLocalArchivedLinks"
      archiveURL="$urlAlreadyContainedInLocalArchivedLinks"
      numSecondsSleep=0
      # echo $archiveURL
      echo "Sleeping for $numSecondsSleep seconds..."
      sleep $numSecondsSleep
      echo ""
    fi
  done < "$links"
  
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
    oss_url="$(getOssFrontend $url)"
    archivedUrl=$( ( grep "$oss_url$" "$archivedLinks"; grep "$oss_url/$" "$archivedLinks") | tail -1)
    if [ "$archivedUrl" != ""  ]; then
      ## echo "Url: $url"
      ## echo "ArchivedUrl: $archivedUrl"
      urlForSed="${url//\//\\/}"
      archiveUrlForSed="${archivedUrl//\//\\/}"
      sed -i "s/$urlForSed)/$urlForSed) ([a]($archiveUrlForSed))/g" "$output"
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
  numLinesErrorFile=$(wc -l "$errors" | awk '{ print $1 }')
  if [ "$numLinesErrorFile" -gt 4 ]; then
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

