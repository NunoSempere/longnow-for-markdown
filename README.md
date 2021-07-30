This package takes a markdown file, and creates a new markdown file in which each link is accompanied by an archive.org link, in the format [...](original link) ([a](archive.org link)).

## How to install
- Add [this file](https://github.com/NunoSempere/longNowForMd/blob/master/longnowformd.sh) to your path, for instance by moving it to the `/usr/bin` folder and giving it execute permissions, or
- copy its content (except the last line) into your .bashrc file, or

This utility requires [archivenow](https://github.com/oduwsdl/archivenow) as a dependency, which itself requires a python installation. It can be installed with

```
$ pip install archivenow ## respectively, pip3
```

## How to use

```
$ longnow file.md
```

For a reasonably sized file, the process will take a long time, so this is more of a "fire and forget, and then come back in a couple of hours" tool. The process can be safely stopped and restarted at any point, and archive links are remembered, but the errors file is created again each time.

## To do
- Deal elegantly with images. Right now, they are also archived, and have to be removed manually afterwards.
- Possibly: Throttle requests to the internet archive less. Right now, I'm sending a link roughly every 12 seconds, and then sleeping for a minute every 15 requests. This is probably too much throttling (the theoretical limit is 15 requests per minute), but I think that it does reduce the error rate. 
- Pull requests are welcome.

## How to use to back up Google Files

You can download a .odt file from Google, and then convert it to a markdown file with 

```
function pandocodt(){
  source="$1.odt"
  output="$1.md"
  pandoc -s "$source" -t markdown-raw_html-native_divs-native_spans-fenced_divs-bracketed_spans | awk ' /^$/ { print "\n"; } /./ { printf("%s ", $0); } END { print ""; } ' | sed -r 's/([0-9]+\.)/\n\1/g' | sed -r 's/\*\*(.*)\*\*/## \1/g'  | tr -s " " | sed -r 's/\\//g' | sed -r 's/\[\*/\[/g' | sed -r 's/\*\]/\]/g' > "$output"
  ## Explanation: 
  ## markdown-raw_html-native_divs-native_spans-fenced_divs-bracketed_spans: various flags to generate some markdown I like
  ## sed -r 's/\*\*(.*)\*\*/## \1/g': transform **Header** into ## Header
  ## sed -r 's/\\//g': Delete annoying "\"s
  ## awk ' /^$/ { print "\n"; } /./ { printf("%s ", $0); } END { print ""; } ': compress paragraphs; see https://unix.stackexchange.com/questions/6910/there-must-be-a-better-way-to-replace-single-newlines-only
  ## sed -r 's/([0-9]*\.)/\n\1/g': Makes lists nicer.
  ## tr -s " ": Replaces multiple spaces
}

## Use: pandocodt YourFileNameWithoutExtension
```

Then run this tool (`longnow YourFileName.md`). Afterwards, convert the output file (`YourFileName.md.longnow`) back to html with 

```
function pandocmd(){
  source="$1.md"
  output="$1.html"
  pandoc -r gfm "$source" -o "$output"
  ## sed -i 's|\[ \]\(([^\)]*)\)| |g' "$source" ## This removes links around spaces, which are very annoying. See https://unix.stackexchange.com/questions/297686/non-greedy-match-with-sed-regex-emulate-perls
}

## Use: pandocmd FileNameWithoutExtension
```

(this requires changing the name of the output file from `YourFileName.md.longnow` to `YourFileName.longnow.md` before running `$ pandocmd YourFileName.longnow`)

Then copy and paste the html into a Google doc and fix fomatting mistakes.
