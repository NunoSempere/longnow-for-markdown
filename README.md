This utility takes a markdown file, and creates a new markdown file in which each link is accompanied by an archive.org link, in the format [...](original link) ([a](archive.org link)).

I use it to archive links in [this forecasting newsletter](https://forecasting.substack.com), which contains the following footer:

> Note to the future: All links are added automatically to the Internet Archive, using this [tool](https://github.com/NunoSempere/longNowForMd) ([a](https://web.archive.org/web/20220109144543/https://github.com/NunoSempere/longNowForMd)). "(a)" for archived links was inspired by [Milan Griffes](https://www.flightfromperfection.com/) ([a](https://web.archive.org/web/20220109144604/https://www.flightfromperfection.com/)), [Andrew Zuckerman](https://www.andzuck.com/) ([a](https://web.archive.org/web/20211202120912/https://www.andzuck.com/)), and [Alexey Guzey](https://guzey.com/) ([a](https://web.archive.org/web/20220109144733/https://guzey.com/)).

## How to install
Add [this file](https://github.com/NunoSempere/longNowForMd/blob/master/longnow) to your path, for instance by moving it to the `/usr/bin` folder and giving it execute permissions (with `chmod 755 longnow`)

```
curl https://raw.githubusercontent.com/NunoSempere/longNowForMd/master/longnow > longnow
cat longnow ## probably a good idea to at least see what's there before giving it execute permissions
sudo chmod 755 longnow
mv longnow /bin/longnow
```

In addition, this utility requires [archivenow](https://github.com/oduwsdl/archivenow) as a dependency, which itself requires a python installation. archivenow can be installed with

```
pip install archivenow ## respectively, pip3
```

It also requires [jq](https://stedolan.github.io/jq/download/), which can be installed as:

```
sudo apt install jq
```

if on Debian, or using your distribution's package manager otherwise.

As of the newest iteration of this program, if archive.org already has a snapshot of the page, that snapshot is taken instead. This results in massive time savings, but could imply that a less up to date copy is used. If this behavior is not desired, it can be easily excised manually, by removing the lines around `if [ "$urlAlreadyInArchiveOnline" == "" ]; then`.

## How to use

```
$ longnow file.md
```

For a reasonably sized file, the process will take a long time, so this is more of a "fire and forget, and then come back in a couple of hours" tool. The process can be safely stopped and restarted at any point, and archive links are remembered, but the errors file is created again each time.

## To do
- Deal elegantly with images. Right now, they are also archived, and have to be removed manually afterwards.
- Possibly: Throttle requests to the internet archive less. Right now, I'm sending a link roughly every 12 seconds, and then sleeping for a minute every 15 requests. This is probably too much throttling (the theoretical limit is 15 requests per minute), but I think that it does reduce the error rate. 
- Do the same thing but for html files, or other formats
- Present to r/DataHoarders
- Pull requests are welcome.

## How to use to back up Google Files

You can download a .odt file from Google, and then convert it to a markdown file with 

```
function odtToMd(){

  input="$1"
  root="$(echo "$input" | sed 's/.odt//g' )"
  output="$root.md"

  pandoc -s "$input" -t markdown-raw_html-native_divs-native_spans-fenced_divs-bracketed_spans | awk ' /^$/ { print "\n"; } /./ { printf("%s ", $0); } END { print ""; } ' | sed -r 's/([0-9]+\.)/\n\1/g' | sed -r 's/\*\*(.*)\*\*/## \1/g'  | tr -s " " | sed -r 's/\\//g' | sed -r 's/\[\*/\[/g' | sed -r 's/\*\]/\]/g' > "$output"
  ## Explanation: 
  ## markdown-raw_html-native_divs-native_spans-fenced_divs-bracketed_spans: various flags to generate some markdown I like
  ## sed -r 's/\*\*(.*)\*\*/## \1/g': transform **Header** into ## Header
  ## sed -r 's/\\//g': Delete annoying "\"s
  ## awk ' /^$/ { print "\n"; } /./ { printf("%s ", $0); } END { print ""; } ': compress paragraphs; see https://unix.stackexchange.com/questions/6910/there-must-be-a-better-way-to-replace-single-newlines-only
  ## sed -r 's/([0-9]*\.)/\n\1/g': Makes lists nicer.
  ## tr -s " ": Replaces multiple spaces
}

## Use: odtToMd file.odt
```

Then run this tool (`longnow file.md`). Afterwards, convert the output file (`file.longnow.md`) back to html with 

```
function mdToHTML(){
  input="$1"
  root="$(echo "$input" | sed 's/.md//g' )"
  output="$root.html"
  pandoc -r gfm "$source" -o "$output"
  ## sed -i 's|\[ \]\(([^\)]*)\)| |g' "$source" ## This removes links around spaces, which are very annoying. See https://unix.stackexchange.com/questions/297686/non-greedy-match-with-sed-regex-emulate-perls
}

## Use: mdToHTML file.md
```

Then copy and paste the html into a Google doc and fix fomatting mistakes.
