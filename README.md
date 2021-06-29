This package takes a markdown file, and creates a new markdown file in which each link is accompanied by an archive.org link, in the format [...](original link) ([a](archive.org link)).

## How to install
Several different ways: 
- Add [this file](https://github.com/NunoSempere/longNowForMd/blob/master/longnowformd.sh) to your path, for instance by moving it to the `/usr/bin` folder and giving it execute permissions, or
- copy its functions into your .bashrc file, or
- for Ubuntu distributions 20.04 (Focal Fossa) and above:

```
$ sudo add-apt-repository ppa:nunosempere/longnowformd
$ sudo apt-get update
$ sudo apt install longnowformd
```

This uses the [nunosempere/longnowformd](https://launchpad.net/~nunosempere/+archive/ubuntu/longnowformd) PPA (Personal Package Archive)

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
