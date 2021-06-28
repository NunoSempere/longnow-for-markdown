function getMdLinks(){ # Use: Takes a markdown file file.md, extracts all links, finds the unique ones and saves them to file.md.links
  echo ""
  echo "Extracting links..."
  
  grep -Eoi '\]\((.*)\)' $1 | grep -Eo '(http|https)://[^)]+' >> "$1.links"
  ## sed -i 's/www.wikiwand.com\/en/en.wikipedia.org\/wiki/g' $1
  awk '!seen[$0]++' "$1.links" > "$1.links2" && mv "$1.links2" "$1.links"
  
  echo "Done."
  echo ""
}

function pushToArchive(){
# Use: Takes a txt file with one link on each line and pushes all the links to the internet archive. Saves those links to a textfile
# References: 
# https://unix.stackexchange.com/questions/181254/how-to-use-grep-and-cut-in-script-to-obtain-website-urls-from-an-html-file
# https://github.com/oduwsdl/archivenow
# For the double underscore, see: https://stackoverflow.com/questions/13797087/bash-why-double-underline-for-private-functions-why-for-bash-complet/15181999	
  echo "Pushing to archive.org..."
  
	input=$1
	counter=1
	
	rm -f "$1.archived"
  touch "$1.archived"
  
	while IFS= read -r line
	do
		wait
		if [ $(($counter % 15)) -eq 0 ]
		then
			printf "\nArchive.org doesn't accept more than 15 links per min; sleeping for 1min...\n"
			sleep 1m
		fi
		echo "Url: $line"
		archiveURL=$(archivenow --ia $line)
		echo $archiveURL >> "$1.archived"
		echo $archiveURL
		counter=$((counter+1))
		echo ""
	done < "$input"
	
	echo "Done."
  echo ""
}

function addArchiveLinksToFile(){
    
  originalFile="$1"
  originalFileTemp="$originalFile.temp"
  linksFile="$1.links"
  archivedLinksFile="$1.links.archived"
  longNowFile="$1.longnow"
  
  echo "Creating longnow file @ $longNowFile..."

	rm -f "$longNowFile"
  touch "$longNowFile"
  cp "$originalFile" "$originalFileTemp"
  
  while IFS= read -r url
	do
		wait

		archivedUrl=$(grep "$url" "$archivedLinksFile" | tail -1)
		## echo "Url: $url"
		## echo "ArchivedUrl: $archivedUrl"
		urlForSed="${url//\//\\/}"
		archiveUrlForSed="${archivedUrl//\//\\/}"
		sed -i "s/$urlForSed)/$urlForSed) ([a]($archiveUrlForSed))/g" "$1"
	done < "$linksFile"
	mv "$originalFile" "$longNowFile"
	mv "$originalFileTemp" "$originalFile"
	
	echo "Done."

}

function longnow(){
  doesArchiveNowExist=$(whereis "archivenow")
  if [ "$doesArchiveNowExist" == "archivenow:" ]
  then
    echo "Required archivenow utility not found in path."
    echo "Install with \$ pip install archivenow"
    echo "(resp. \$ pip3 install archivenow)"
    echo "Or follow instructions on https://github.com/oduwsdl/archivenow"
  else
    getMdLinks $1
    pushToArchive $1.links
    addArchiveLinksToFile $1
  fi 
}

