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
